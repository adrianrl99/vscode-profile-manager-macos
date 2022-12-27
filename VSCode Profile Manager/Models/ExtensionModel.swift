import Foundation
import SwiftDate

struct ExtensionModel: Identifiable, Decodable, Hashable {
    var id: Int64? = nil

    let extensionId: UUID
    let extensionName: String
    let displayName: String
    let lastUpdated: DateInRegion
    let shortDescription: String?
    let verified: Bool
    let publisherName: String

    var installed: Bool = false
    var version: String? = nil
    var image: Data? = nil
    var imageURL: URL? = nil
    var vsixURL: URL? = nil
    var installs: String? = nil
    var averagerating: String? = nil

    enum CodingKeys: String, CodingKey {
        case extensionId
        case extensionName
        case displayName
        case lastUpdated
        case shortDescription
        case flags
        case publisher
        case versions
        case statistics
    }

    init(id: Int64,
         extensionId: UUID,
         extensionName: String,
         displayName: String,
         lastUpdated: DateInRegion,
         shortDescription: String?,
         verified: Bool,
         publisherName: String,
         installed: Bool,
         version: String?,
         imageURL: URL?,
         vsixURL: URL?,
         installs: String?,
         averagerating: String?)
    {
        self.id = id
        self.extensionId = extensionId
        self.extensionName = extensionName
        self.displayName = displayName
        self.lastUpdated = lastUpdated
        self.shortDescription = shortDescription
        self.verified = verified
        self.publisherName = publisherName
        self.installed = installed
        self.version = version
        self.imageURL = imageURL
        self.vsixURL = vsixURL
        self.installs = installs
        self.averagerating = averagerating
    }

    init(from decoder: Decoder) throws {
        installed = false
        let container = try decoder.container(keyedBy: CodingKeys.self)
        extensionId = try container.decode(UUID.self, forKey: .extensionId)
        extensionName = try container.decode(String.self, forKey: .extensionName)
        displayName = try container.decode(String.self, forKey: .displayName)
        lastUpdated = try container.decode(String.self, forKey: .lastUpdated).toISODate()!
        shortDescription = try? container.decode(String.self, forKey: .shortDescription)
        verified = try container.decode(String.self, forKey: .flags)
            .split(separator: ", ")
            .map { FlagType(rawValue: String($0)) ?? .unknown }
            .contains(.verified)
        publisherName = try container.decode(
            Publisher.self,
            forKey: .publisher
        ).publisherName

        if let version = try container.decode(
            [Version].self,
            forKey: .versions
        ).first {
            self.version = version.version

            if let files = version.files {
                if let file = files
                    .first(where: {
                        $0.assetType == .ServicesIconSmall || $0.assetType == .ServicesIconDefault
                    })
                {
                    imageURL = file.source
                }

                if let file = files
                    .first(where: {
                        $0.assetType == .ServicesVSIXPackage
                    })
                {
                    vsixURL = file.source
                }
            }
        }

        if let statistics = try? container
            .decode([Statistics].self, forKey: .statistics)
        {
            if let installs = statistics.first(where: { $0.statisticName == .install })?.value {
                self.installs = installs.quantityString()
            }

            if let averagerating = statistics.first(where: { $0.statisticName == .averagerating })?
                .value
            {
                self.averagerating = averagerating.fixedString()
            }
        }
    }

    enum FlagType: String, Decodable {
        case verified
        case `public`
        case preview

        case unknown
    }

    struct Publisher: Decodable {
        let publisherName: String
    }

    struct Version: Decodable {
        let version: String
        let files: [File]?
    }

    enum AssetType: String, Codable {
        case ServicesVSIXPackage = "Microsoft.VisualStudio.Services.VSIXPackage"
        case ServicesIconDefault = "Microsoft.VisualStudio.Services.Icons.Default"
        case ServicesIconSmall = "Microsoft.VisualStudio.Services.Icons.Small"

        case unknown
    }

    struct File: Decodable {
        let assetType: AssetType
        let source: URL

        enum CodingKeys: String, CodingKey {
            case assetType
            case source
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            assetType = (try? container.decode(AssetType.self, forKey: .assetType)) ?? .unknown
            source = try container.decode(URL.self, forKey: .source)
        }
    }

    enum StatisticsType: String, Decodable {
        case install
        case averagerating

        case unknown
    }

    struct Statistics: Decodable {
        let statisticName: StatisticsType
        let value: Double

        enum CodingKeys: String, CodingKey {
            case statisticName
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            statisticName = (try? container.decode(StatisticsType.self, forKey: .statisticName)) ??
                .unknown
            value = try container.decode(Double.self, forKey: .value)
        }
    }

    enum TargetType: String, Decodable {
        case Code = "Microsoft.VisualStudio.Code"
    }

    struct Filters: Encodable {
        var flags: [FlagType] = [.None]
        let assetTypes: [AssetType] = []
        let filters: [Filter]

        enum CodingKeys: String, CodingKey {
            case flags
            case assetTypes
            case filters
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
                flags
                    .reduce(FlagType.None.rawValue) { $0 | $1.rawValue },
                forKey: CodingKeys.flags
            )
            try container.encode(assetTypes, forKey: CodingKeys.assetTypes)
            try container.encode(filters, forKey: CodingKeys.filters)
        }

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
        }
    }

    struct Results: Decodable {
        var results: [Result]

        struct Error: Decodable {
            let success: Bool
            let message: String
        }

        struct Result: Decodable {
            var extensions: [ExtensionModel]
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

                enum CodingKeys: String, CodingKey {
                    case metadataType
                    case metadataItems
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    metadataType = (try? container
                        .decode(MetadataType.self, forKey: .metadataType)) ?? .unknown
                    metadataItems = try container.decode([Item].self, forKey: .metadataItems)
                }

                struct Item: Decodable {
                    let name: Name
                    let count: UInt

                    enum CodingKeys: String, CodingKey {
                        case name
                        case count
                    }

                    init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: CodingKeys.self)
                        name = (try? container.decode(Name.self, forKey: .name)) ?? .unknown
                        count = try container.decode(UInt.self, forKey: .count)
                    }

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
}
