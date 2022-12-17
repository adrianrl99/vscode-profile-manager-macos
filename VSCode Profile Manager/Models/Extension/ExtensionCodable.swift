import Foundation
import SwiftDate

extension ExtensionModel {
    enum CodingKeys: String, CodingKey {
        case extensionId
        case extensionName
        case displayName
        case shortDescription
        case publisher
        case statistics
        case versions
        case tags
        case releaseDate
        case publishedDate
        case lastUpdated
        case categories
        case flags
        case deploymentType
        case installationTargets
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        extensionId = try container.decode(UUID.self, forKey: CodingKeys.extensionId)
        extensionName = try container.decode(String.self, forKey: CodingKeys.extensionName)
        displayName = try container.decode(String.self, forKey: CodingKeys.displayName)
        shortDescription = try container.decode(String.self, forKey: CodingKeys.shortDescription)
        publisher = try container.decode(Publisher.self, forKey: CodingKeys.publisher)
        statistics = try? container.decode([Statistics].self, forKey: CodingKeys.statistics)
        versions = try container.decode([Version].self, forKey: CodingKeys.versions)
        tags = try? container.decode([String].self, forKey: CodingKeys.tags)
        releaseDate = try container.decode(String.self, forKey: CodingKeys.releaseDate).toISODate()!
        publishedDate = try container.decode(String.self, forKey: CodingKeys.publishedDate)
            .toISODate()!
        lastUpdated = try container.decode(String.self, forKey: CodingKeys.lastUpdated).toISODate()!
        categories = try? container.decode([String].self, forKey: CodingKeys.categories)
        flags = try container.decode(String.self, forKey: CodingKeys.flags).split(separator: ", ")
            .map { ExtensionModel.FlagType(rawValue: String($0)) ?? .unknown }
        deploymentType = try container.decode(UInt.self, forKey: CodingKeys.deploymentType)
        installationTargets = try? container.decode(
            [InstallationTarget].self,
            forKey: CodingKeys.installationTargets
        )
    }
}

extension ExtensionModel.Publisher {
    enum CodingKeys: String, CodingKey {
        case displayName
        case publisherId
        case publisherName
        case domain
        case isDomainVerified
        case flags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decode(String.self, forKey: CodingKeys.displayName)
        publisherId = try container.decode(UUID.self, forKey: CodingKeys.publisherId)
        publisherName = try container.decode(String.self, forKey: CodingKeys.publisherName)
        domain = try? container.decode(URL.self, forKey: CodingKeys.domain)
        isDomainVerified = try container.decode(Bool.self, forKey: CodingKeys.isDomainVerified)
        flags = try container.decode(String.self, forKey: CodingKeys.flags).split(separator: ", ")
            .map { ExtensionModel.FlagType(rawValue: String($0)) ?? .unknown }
    }
}

extension ExtensionModel.Version {
    enum CodingKeys: String, CodingKey {
        case version
        case lastUpdated
        case assetUri
        case fallbackAssetUri
        case files
        case properties
        case targetPlatform
        case flags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: CodingKeys.version)
        lastUpdated = try container.decode(String.self, forKey: CodingKeys.lastUpdated).toISODate()!
        assetUri = try? container.decode(URL.self, forKey: CodingKeys.assetUri)
        fallbackAssetUri = try? container.decode(URL.self, forKey: CodingKeys.fallbackAssetUri)
        files = try? container.decode([ExtensionModel.File].self, forKey: CodingKeys.files)
        properties = try? container.decode(
            [ExtensionModel.Property].self,
            forKey: CodingKeys.properties
        )
        targetPlatform = try? container.decode(String.self, forKey: CodingKeys.targetPlatform)
        flags = try container.decode(String.self, forKey: CodingKeys.flags).split(separator: ", ")
            .map { ExtensionModel.FlagType(rawValue: String($0)) ?? .unknown }
    }
}

extension ExtensionModel.File {
    enum CodingKeys: String, CodingKey {
        case assetType
        case source
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetType = (try? container.decode(
            ExtensionModel.AssetType.self,
            forKey: CodingKeys.assetType
        )) ?? .unknown
        source = try container.decode(URL.self, forKey: CodingKeys.source)
    }
}

extension ExtensionModel.Property {
    enum CodingKeys: String, CodingKey {
        case key
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = (try? container.decode(
            ExtensionModel.PropertyType.self,
            forKey: CodingKeys.key
        )) ?? .unknown
        value = try container.decode(String.self, forKey: CodingKeys.value)
    }
}

extension ExtensionModel.Statistics {
    enum CodingKeys: String, CodingKey {
        case statisticName
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statisticName = (try? container.decode(
            ExtensionModel.StatisticsType.self,
            forKey: CodingKeys.statisticName
        )) ?? .unknown
        value = try container.decode(Double.self, forKey: CodingKeys.value)
    }
}

extension ExtensionModel.Result.Metadata {
    enum CodingKeys: String, CodingKey {
        case metadataType
        case metadataItems
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metadataType = (try? container.decode(
            ExtensionModel.Result.MetadataType.self,
            forKey: CodingKeys.metadataType
        )) ?? .unknown
        metadataItems = try container.decode([Item].self, forKey: CodingKeys.metadataItems)
    }
}

extension ExtensionModel.Result.Metadata.Item {
    enum CodingKeys: String, CodingKey {
        case name
        case count
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = (try? container.decode(
            ExtensionModel.Result.Metadata.Item.Name.self,
            forKey: CodingKeys.name
        )) ?? .unknown
        count = try container.decode(UInt.self, forKey: CodingKeys.count)
    }
}

extension ExtensionModel.Filters {
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
}
