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
        /// need adapt finished date not found in any payload
        guard let body = request.body,
            let bodyData: Data = body.data(using: .utf8),
            let payload = try? decoder.decode(WebhookPayload.self, from: bodyData),
            payload.metadata.attributes.eventType == .completed else {
            return .init(statusCode: .badRequest, body: "Empty request body")
        }

        let response = formatPayloadResponse(payload)
        print("Formatted response: \(response)")
        return .init(statusCode: .ok, body: response)
    }

    private func formatPayloadResponse(_ payload: WebhookPayload) -> String {
        """
        Xcode Cloud Build Summary:
        - Workflow: \(payload.ciWorkflow.attributes.name)
        - CI Workflow Id: \(payload.ciWorkflow.id)
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
