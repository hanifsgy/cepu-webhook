import AWSLambdaRuntime
import AWSLambdaEvents
import AsyncHTTPClient
import Foundation

@main
struct CepuWebhook: SimpleLambdaHandler {
    let decoder: JSONDecoder
    
    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }
    
    func handle(_ request: APIGatewayV2Request, context: LambdaContext) async throws -> APIGatewayV2Response {
        guard let body = request.body,
              let bodyData = body.data(using: .utf8) else {
            return .init(statusCode: .badRequest, body: "Invalid request body")
        }
        
        do {
            let payload = try decoder.decode(WebhookPayload.self, from: bodyData)
            
            // Check if the event type is completed, will revisit based on conditions
            guard payload.metadata.attributes.eventType == .completed else {
                // Return early if the event type is not completed
                return .init(statusCode: .ok, body: "Event type is not completed")
            }
            
            let response = formatPayloadResponse(payload)
            print("Formatted response: \(response)")
            
            /// Prepare Payload for Gitlab Trigger
            /// variables:
            /// - XCODE_CLOUD_WORKFLOW_ID
            /// - XCODE_CLOUD_WORKFLOW_NAME
            /// - Artifact (Adjustable based on Environment Variable)
            let gitlabTriggerPayload = GitlabTriggerPayload(
                variables: [
                    "XCODE_CLOUD_CI_WORKFLOW_ID": payload.ciWorkflow.id,
                    "XCODE_CLOUD_CI_WORKFLOW_NAME": payload.ciWorkflow.attributes.name,
                    "XCODE_CLOUD_CI_ARTIFACT": Environment.artifact
                ],
                token: Environment.gitLabToken,
                ref: payload.scmGitReference.attributes.name
            )
            print("Gitlab Trigger Payload: \(gitlabTriggerPayload)")
            
            /// gitlab trigger pipeline response
            let gitlabResponse = try await triggerGitlabPipeline(payload: gitlabTriggerPayload)
            
            return .init(statusCode: .ok, body: gitlabResponse)
        } catch DecodingError.keyNotFound(let key, let context) {
            let errorMessage = "Missing key '\(key.stringValue)' in \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))"
            print("Decoding error: \(errorMessage)")
            return .init(statusCode: .badRequest, body: errorMessage)
        } catch DecodingError.typeMismatch(let type, let context) {
            let errorMessage = "Type mismatch for key '\(context.codingPath.last?.stringValue ?? "")': expected \(type), in \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))"
            print("Decoding error: \(errorMessage)")
            return .init(statusCode: .badRequest, body: errorMessage)
        } catch {
            let errorMessage = "Failed to decode payload: \(error.localizedDescription)"
            print("Decoding error: \(errorMessage)")
            return .init(statusCode: .badRequest, body: errorMessage)
        }
    }
    
    private func formatPayloadResponse(_ payload: WebhookPayload) -> String {
        """
        Xcode Cloud Build Summary:
        - Workflow: \(payload.ciWorkflow.attributes.name)
        - CI Workflow Id: \(payload.ciWorkflow.id)
        - Repository: \(payload.scmRepository.attributes.repositoryName)
        - Branch/Tag: \(payload.scmGitReference.attributes.name) (\(payload.scmGitReference.attributes.kind))
        - Status: \(payload.ciBuildRun.attributes.completionStatus ?? "")
        - Started: \(payload.ciBuildRun.attributes.startedDate ?? "")
        - Finished: \(payload.ciBuildRun.attributes.finishedDate ?? "")
        - Progress: \(payload.ciBuildRun.attributes.executionProgress)
        - Author: \(payload.ciBuildRun.attributes.sourceCommit.author.displayName)
        """
    }
    
    func triggerGitlabPipeline(payload: GitlabTriggerPayload) async throws -> String {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        defer { try? httpClient.syncShutdown() }
        
        var components = URLComponents(string: GitlabAPI.baseURL)!
        components.queryItems = [URLQueryItem(name: "ref", value: payload.ref)]
        
        guard let url = components.url else {
            throw NSError(domain: "URLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to construct URL"])
        }
        
        var request = HTTPClientRequest(url: url.absoluteString)
        request.method = .POST
        request.headers.add(name: "PRIVATE-TOKEN", value: payload.token)
        request.headers.add(name: "Content-Type", value: "application/json")
        
        let variables = payload.variables.map { ["key": $0.key, "value": $0.value] }
        let body: [String: Any] = ["variables": variables]
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.body = .bytes(jsonData)
        
        print("GitLab API URL: \(url)")
        print("Request method: \(request.method)")
        print("Request headers: \(request.headers)")
        print("Request body: \(String(data: jsonData, encoding: .utf8) ?? "Unable to print body")")
        
        do {
            let response = try await httpClient.execute(request, timeout: .seconds(30))
            
            print("Response status: \(response.status)")
            print("Response headers: \(response.headers)")
            
            let bodyBytes = try await response.body.collect(upTo: 1024 * 1024) // 1 MB max
            let responseBody = String(buffer: bodyBytes)
            print("Response body: \(responseBody)")
            
            guard (200...299).contains(response.status.code) else {
                throw NSError(domain: "GitLabAPIError", code: Int(response.status.code),
                              userInfo: [NSLocalizedDescriptionKey: "Failed to trigger GitLab CI job. Status: \(response.status)"])
            }
            
            return responseBody
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
}
