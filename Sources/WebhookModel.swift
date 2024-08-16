struct WebhookPayload: Decodable {
    let webhook: Webhook
    let metadata: Metadata
    let app: App
    let ciWorkflow: CIWorkflow
    let ciProduct: CIProduct
    let ciBuildRun: CIBuildRun
    let ciBuildActions: [CIBuildAction]
    let scmProvider: SCMProvider
    let scmRepository: SCMRepository
    let scmGitReference: SCMGitReference

    struct Webhook: Decodable {
        let id: String
        let name: String
        let url: String
    }

    struct Metadata: Decodable {
        let type: String
        let attributes: MetadataAttributes

        struct MetadataAttributes: Decodable {
            let createdDate: String
            let eventType: String
        }
    }

    struct App: Decodable {
        let id: String
        let type: String
    }

    struct CIWorkflow: Decodable {
        let id: String
        let type: String
        let attributes: CIWorkflowAttributes

        struct CIWorkflowAttributes: Decodable {
            let name: String
            let description: String
            let lastModifiedDate: String
            let isEnabled: Bool
            let isLockedForEditing: Bool
        }
    }

    struct CIProduct: Decodable {
        let id: String
        let type: String
        let attributes: CIProductAttributes

        struct CIProductAttributes: Decodable {
            let name: String
            let createdDate: String
            let productType: String
        }
    }

    struct CIBuildRun: Decodable {
        let id: String
        let type: String
        let attributes: CIBuildRunAttributes

        struct CIBuildRunAttributes: Decodable {
            let number: Int
            let createdDate: String
            let startedDate: String
            let finishedDate: String
            let sourceCommit: SourceCommit
            let isPullRequestBuild: Bool
            let executionProgress: String
            let completionStatus: String

            struct SourceCommit: Decodable {
                let commitSha: String
                let author: Author
                let committer: Committer
                let htmlUrl: String

                struct Author: Decodable {
                    let displayName: String
                }

                struct Committer: Decodable {
                    let displayName: String
                }
            }
        }
    }

    struct CIBuildAction: Decodable {
        let id: String
        let type: String
        let attributes: CIBuildActionAttributes

        struct CIBuildActionAttributes: Decodable {
            let name: String
            let actionType: String
            let startedDate: String
            let finishedDate: String
            let issueCounts: IssueCounts
            let executionProgress: String
            let completionStatus: String
            let isRequiredToPass: Bool

            struct IssueCounts: Decodable {
                let analyzerWarnings: Int
                let errors: Int
                let testFailures: Int
                let warnings: Int
            }
        }
    }

    struct SCMProvider: Decodable {
        let type: String
        let attributes: SCMProviderAttributes

        struct SCMProviderAttributes: Decodable {
            let scmProviderType: SCMProviderType
            let endpoint: String

            struct SCMProviderType: Decodable {
                let scmProviderType: String
                let displayName: String
                let isOnPremise: Bool
            }
        }
    }

    struct SCMRepository: Decodable {
        let id: String
        let type: String
        let attributes: SCMRepositoryAttributes

        struct SCMRepositoryAttributes: Decodable {
            let httpCloneUrl: String
            let sshCloneUrl: String
            let ownerName: String
            let repositoryName: String
        }
    }

    struct SCMGitReference: Decodable {
        let id: String
        let type: String
        let attributes: SCMGitReferenceAttributes

        struct SCMGitReferenceAttributes: Decodable {
            let name: String
            let canonicalName: String
            let isDeleted: Bool
            let kind: String
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

struct APIGatewayEvent: Decodable {
    let version: String
    let routeKey: String
    let rawPath: String
    let rawQueryString: String
    let headers: [String: String]
    let requestContext: RequestContext
    let body: String
    let isBase64Encoded: Bool

    struct RequestContext: Decodable {
        let accountId: String
        let apiId: String
        let domainName: String
        let domainPrefix: String
        let http: HTTPInfo
        let requestId: String
        let routeKey: String
        let stage: String
        let time: String
        let timeEpoch: Int64

        struct HTTPInfo: Decodable {
            let method: String
            let path: String
            let `protocol`: String
            let sourceIp: String
            let userAgent: String
        }
    }
}