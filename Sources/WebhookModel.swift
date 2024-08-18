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
            let eventType: BuildMetaDataStatus
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

enum BuildMetaDataStatus: String, Decodable {
    case completed = "BUILD_COMPLETED"
    case started = "BUILD_STARTED"
    case pending = "BUILD_CREATED"
}