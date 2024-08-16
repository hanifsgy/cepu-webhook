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
        print("Received request: \(request)")
        
        guard let body = request.body else {
            print("Error: Empty request body")
            return .init(statusCode: .badRequest, body: "Empty request body")
        }
        
        print("Raw body: \(body)")
        guard let bodyData = body.data(using: .utf8) else {
            print("Error: Could not convert body to data")
            return .init(statusCode: .badRequest, body: "Invalid request body encoding")
        }
        
        do {
            // Try to parse as generic JSON first
            let payload = try decoder.decode(WebhookPayload.self, from: bodyData)
            let response = formatPayloadResponse(payload)
            print("Formatted response: \(response)")
            
            return .init(statusCode: .ok, body: response)
        } catch {
            print("Error decoding payload: \(error)")
            if let decodingError = error as? DecodingError {
                print("Decoding error details: \(decodingError)")
            }
            return .init(statusCode: .badRequest, body: "Could not parse the request content: \(error.localizedDescription)")
        }
    }

    private func formatPayloadResponse(_ payload: WebhookPayload) -> String {
        """
        Xcode Cloud Build Summary:
        - Workflow: \(payload.ciWorkflow.attributes.name)
        - Repository: \(payload.scmRepository.attributes.repositoryName)
        - Branch/Tag: \(payload.scmGitReference.attributes.name) (\(payload.scmGitReference.attributes.kind))
        - Status: \(payload.ciBuildRun.attributes.completionStatus)
        - Started: \(payload.ciBuildRun.attributes.startedDate)
        - Finished: \(payload.ciBuildRun.attributes.finishedDate)
        - Progress: \(payload.ciBuildRun.attributes.executionProgress)
        - Author: \(payload.ciBuildRun.attributes.sourceCommit.author.displayName)
        """
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
