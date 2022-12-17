import AnyCodable
import SwiftDate
import SwiftUI

struct ExtensionModel: Decodable {
    let extensionId: UUID
    let extensionName: String
    let displayName: String
    let shortDescription: String?
    let publisher: Publisher
    let statistics: [Statistics]?
    let versions: [Version]
    let tags: [String]?
    let releaseDate: DateInRegion
    let publishedDate: DateInRegion
    let lastUpdated: DateInRegion
    let categories: [String]?
    let flags: [FlagType]
    let deploymentType: UInt
    let installationTargets: [InstallationTarget]?

    var image: NSImage? = nil
    var installs: String? = nil
    var averagerating: String? = nil
    var packageSize: String? = nil

    struct Card: Hashable {
        let displayName: String
        let releaseDate: DateInRegion
        let shortDescription: String?
        let verified: Bool
        let publisherName: String

        var image: NSImage? = nil
        var installs: String? = nil
        var averagerating: String? = nil
        var packageSize: String? = nil
        var version: String? = nil
    }

    enum FlagType: String, Decodable {
        case verified
        case `public`
        case preview

        case unknown
    }

    struct InstallationTarget: Decodable {
        let target: TargetType
        let targetVersion: String
    }

    enum TargetType: String, Decodable {
        case Code = "Microsoft.VisualStudio.Code"
    }

    struct Publisher: Decodable {
        let displayName: String
        let publisherId: UUID
        let publisherName: String
        let domain: URL?
        let isDomainVerified: Bool
        let flags: [FlagType]
    }

    struct Version: Decodable {
        let version: String
        let lastUpdated: DateInRegion
        let assetUri: URL?
        let fallbackAssetUri: URL?
        let files: [File]?
        let properties: [Property]?
        let targetPlatform: String?
        let flags: [FlagType]
    }

    struct File: Decodable {
        let assetType: AssetType
        let source: URL
    }

    enum AssetType: String, Codable {
        // Code
        case CodeManifest = "Microsoft.VisualStudio.Code.Manifest"
        case CodeExtensionDependencies = "Microsoft.VisualStudio.Code.ExtensionDependencies"

        // Services
        case ServicesVsixManifest = "Microsoft.VisualStudio.Services.VsixManifest"
        case ServicesVSIXPackage = "Microsoft.VisualStudio.Services.VSIXPackage"

        // Services Content
        case ServicesContentChangelog = "Microsoft.VisualStudio.Services.Content.Changelog"
        case ServicesContentDetails = "Microsoft.VisualStudio.Services.Content.Details"
        case ServicesContentLicense = "Microsoft.VisualStudio.Services.Content.License"

        // Services Icons
        case ServicesIconDefault = "Microsoft.VisualStudio.Services.Icons.Default"
        case ServicesIconSmall = "Microsoft.VisualStudio.Services.Icons.Small"

        case unknown
    }

    enum PropertyType: String, Decodable {
        // Code
        case CodeExtensionDependencies = "Microsoft.VisualStudio.Code.ExtensionDependencies"
        case CodeExtensionPack = "Microsoft.VisualStudio.Code.ExtensionPack"
        case CodeEngine = "Microsoft.VisualStudio.Code.Engine"
        case CodeLocalizedLanguages = "Microsoft.VisualStudio.Code.LocalizedLanguages"
        case CodeExtensionKind = "Microsoft.VisualStudio.Code.ExtensionKind"

        // Services
        case ServiecsSignature = "Microsoft.VisualStudio.Services.VsixSignature"
        case ServicesGitHubFlavoredMarkdown =
            "Microsoft.VisualStudio.Services.GitHubFlavoredMarkdown"
        case ServicesCustomerQnALink = "Microsoft.VisualStudio.Services.CustomerQnALink"

        // Services Branding
        case ServicesBrandingColor = "Microsoft.VisualStudio.Services.Branding.Color"
        case ServicesBrandingTheme = "Microsoft.VisualStudio.Services.Branding.Theme"

        // Services Links
        case ServicesLinksGetStarted = "Microsoft.VisualStudio.Services.Links.Getstarted"
        case ServicesLinksSupport = "Microsoft.VisualStudio.Services.Links.Support"
        case ServicesLinksLearn = "Microsoft.VisualStudio.Services.Links.Learn"
        case ServicesLinksSource = "Microsoft.VisualStudio.Services.Links.Source"
        case ServicesLinksGitHub = "Microsoft.VisualStudio.Services.Links.GitHub"

        case unknown
    }

    struct Property: Decodable {
        let key: PropertyType
        let value: String
    }

    enum StatisticsType: String, Decodable {
        case install
        case averagerating
        case ratingcount
        case trendingdaily
        case trendingmonthly
        case trendingweekly
        case updateCount
        case weightedRating
        case downloadCount

        case unknown
    }

    struct Statistics: Decodable {
        let statisticName: StatisticsType
        let value: Double
    }

    struct Filters: Encodable {
        var flags: [FlagType] = [.None]
        let assetTypes: [AssetType] = []
        let filters: [Filter]

        enum FlagType: UInt, Encodable {
            /**
             * None is used to retrieve only the basic extension details.
             */
            case None = 0x0

            /**
             * IncludeVersions will return version information for extensions returned
             */
            case IncludeVersions = 0x1

            /**
             * IncludeFiles will return information about which files were found
             * within the extension that were stored independent of the manifest.
             * When asking for files, versions will be included as well since files
             * are returned as a property of the versions.
             * These files can be retrieved using the path to the file without
             * requiring the entire manifest be downloaded.
             */
            case IncludeFiles = 0x2

            /**
             * Include the Categories and Tags that were added to the extension definition.
             */
            case IncludeCategoryAndTags = 0x4

            /**
             * Include the details about which accounts the extension has been shared
             * with if the extension is a private extension.
             */
            case IncludeSharedAccounts = 0x8

            /**
             * Include properties associated with versions of the extension
             */
            case IncludeVersionProperties = 0x10

            /**
             * Excluding non-validated extensions will remove any extension versions that
             * either are in the process of being validated or have failed validation.
             */
            case ExcludeNonValidated = 0x20

            /**
             * Include the set of installation targets the extension has requested.
             */
            case IncludeInstallationTargets = 0x40

            /**
             * Include the base uri for assets of this extension
             */
            case IncludeAssetUri = 0x80

            /**
             * Include the statistics associated with this extension
             */
            case IncludeStatistics = 0x100

            /**
             * When retrieving versions from a query, only include the latest
             * version of the extensions that matched. This is useful when the
             * caller doesn't need all the published versions. It will save a
             * significant size in the returned payload.
             */
            case IncludeLatestVersionOnly = 0x200

            /**
             * This flag switches the asset uri to use GetAssetByName instead of CDN
             * When this is used, values of base asset uri and base asset uri fallback are switched
             * When this is used, source of asset files are pointed to Gallery service always even if CDN is available
             */
            case Unpublished = 0x1000

            /**
             * Include the details if an extension is in conflict list or not
             */
            case IncludeNameConflictInfo = 0x8000
        }
    }

    struct Filter: Encodable {
        let pageNumber: UInt
        let pageSize: UInt
        let sortBy: UInt
        let sortOrder: UInt
        let criteria: [Criterium]

        init(
            pageNumber: UInt = 1,
            pageSize: UInt = 4,
            sortBy: UInt = 0,
            sortOrder: UInt = 0,
            criteria: [Criterium] = []
        ) {
            self.pageNumber = pageNumber
            self.pageSize = pageSize
            self.sortBy = sortBy
            self.sortOrder = sortOrder
            self
                .criteria = [Criterium(filterType: .Target, value: TargetType.Code.rawValue)] +
                criteria
        }

        struct Criterium: Encodable {
            let filterType: FilterType
            var value: String? = nil
        }
    }

    enum FilterType: UInt, Encodable {
        case Tag = 1
        case ExtensionId = 4
        case Category = 5
        case ExtensionName = 7
        case Target = 8
        case Featured = 9
        case SearchText = 10
        case ExcludeWithFlags = 12
    }

    struct Results: Decodable {
        var results: [Result]
    }

    struct Result: Decodable {
        var extensions: [ExtensionModel]
        let pagingToken: AnyDecodable?
        let resultMetadata: [Metadata]

        enum MetadataType: String, Decodable {
            case ResultCount
            case Categories
            case TargetPlatforms

            case unknown
        }

        struct Metadata: Decodable {
            let metadataType: MetadataType
            let metadataItems: [Item]

            struct Item: Decodable {
                let name: Name
                let count: UInt

                enum Name: String, Decodable {
                    case TotalCount
                    case Other
                    case Programming_Languages = "Programming Languages"
                    case Snippets
                    case Extension_Packs = "Extension Packs"
                    case Themes
                    case Formatters
                    case Linters
                    case Debuggers
                    case Machine_Learning = "Machine Learning"
                    case Data_Science = "Data Science"
                    case Visualization
                    case Notebooks
                    case Education
                    case Testing
                    case Keymaps
                    case Language_Packs = "Language Packs"
                    case Azure
                    case SCM_Providers = "SCM Providers"
                    case universal
                    case web
                    case darwin_arm64 = "darwin-arm64"
                    case linux_x64 = "linux-x64"
                    case darwin_x64 = "darwin-x64"
                    case win32_x64 = "win32-x64"
                    case linux_arm64 = "linux-arm64"
                    case linux_armhf = "linux-armhf"
                    case win32_arm64 = "win32-arm64"

                    case unknown
                }
            }
        }
    }
}
