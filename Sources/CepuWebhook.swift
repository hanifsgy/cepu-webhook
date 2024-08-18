import AWSLambdaRuntime
import AWSLambdaEvents
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
            // TODO: Need to rnd related gitlab, and appstore connect api integrations
            return .init(statusCode: .ok, body: response)
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
}
