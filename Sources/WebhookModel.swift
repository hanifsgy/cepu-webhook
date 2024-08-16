import Foundation

struct WebhookPayload: Decodable {
  let ciBuildRun: CIBuildRun
  let ciWorkflow: CIWorkflow
  let scmGitReference: SCMGitReference
  let scmRepository: SCMRepository

  struct CIBuildRun: Decodable {
    let attributes: Attributes

    struct Attributes: Decodable {
      let completionStatus: CompletionStatus
      let startedDate: Date
      let executionProgress: String
      let finishedDate: Date
      let sourceCommit: SourceCommit

      struct SourceCommit: Decodable {
        let author: Author

        struct Author: Decodable {
          let displayName: String
        }
      }
    }
  }

  struct CIWorkflow: Decodable {
    let attributes: Attributes

    struct Attributes: Decodable {
      let name: String
    }
  }

  struct SCMGitReference: Decodable {
    let attributes: Attributes

    struct Attributes: Decodable {
      let name: String
      let kind: String
    }
  }

  struct SCMRepository: Decodable {
    let attributes: Attributes

    struct Attributes: Decodable {
      let repositoryName: String
    }
  }
}

enum CompletionStatus: String, Decodable {
    case succeeded = "SUCCEEDED"
    case failed = "FAILED"
    case errored = "ERRORED"
    case canceled = "CANCELED"
    case skipped = "SKIPPED"
}
