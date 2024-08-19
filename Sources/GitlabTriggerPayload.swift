import Foundation

struct GitlabTriggerPayload: Codable {
    let variables: [String: String]
    let token: String 
    let ref: String 
}

enum GitlabAPIAction {
    case triggerPipeline(projectId: String, payload: GitlabTriggerPayload)
}   

/// https://docs.gitlab.com/ee/ci/triggers/#use-curl
struct GitlabAPI {
    static let baseURL = "\(Environment.gitLabApiUrl)/projects/\(Environment.gitLabProjectId)/trigger/pipeline"
}

enum Environment {
    static let gitLabApiUrl = ProcessInfo.processInfo.environment["GITLAB_API_URL"]!
    static let gitLabToken = ProcessInfo.processInfo.environment["GITLAB_TOKEN"]!
    static let gitLabProjectId = ProcessInfo.processInfo.environment["GITLAB_PROJECT_ID"]!
    static let artifact: String = ProcessInfo.processInfo.environment["XCODE_CLOUD_ARTIFACT"]!
}