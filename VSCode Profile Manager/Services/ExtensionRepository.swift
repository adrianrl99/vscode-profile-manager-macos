import AppKit
import FileKit
import Foundation

struct ExtensionRepository {
    private let path: Path

    private let url =
        URL(string: "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery")!

    private var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "application/json;api-version=3.0-preview.1",
            forHTTPHeaderField: "Accept"
        )
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        return request
    }

    init(base: Path = Path.userHome + ".Vscode Profile Manager") {
        path = base + "extensions"

        if !base.exists {
            try! base.createDirectory(withIntermediateDirectories: true)
        }

        if !path.exists {
            try! path.createDirectory(withIntermediateDirectories: true)
        }
    }

    private func cacheData(base: Path, type: ExtensionModel.AssetType, data: Data) throws {
        if !base.exists {
            try base.createDirectory(withIntermediateDirectories: true)
        }
        let file = File<Data>(path: base + type.rawValue)
        try data |> file
    }

    private func downloadFile(file: ExtensionModel.File) async throws -> Data {
        let request = URLRequest(url: file.source)
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }

    private func getFile(ext: ExtensionModel, file: ExtensionModel.File) async throws -> Data {
        let base = (path + ext.extensionName + ext.versions.first!.version)
        let cached = File<Data>(path: base + file.assetType.rawValue)
        if let data = try? cached.read() {
            return data
        }

        let data = try await downloadFile(file: file)
        try cacheData(
            base: base,
            type: file.assetType,
            data: data
        )

        return data
    }

    private func getExtensions(
        filter: ExtensionModel.Filter,
        flags: [ExtensionModel.Filters.FlagType] = []
    ) async throws -> [ExtensionModel.Card] {
        let filters = ExtensionModel.Filters(
            flags: [.IncludeLatestVersionOnly, .IncludeStatistics, .IncludeFiles] + flags,
            filters: [filter]
        )

        let encoder = JSONEncoder()
        let body = try! encoder.encode(filters)

        var request = self.request
        request.httpBody = body
        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
        let result = try decoder.decode(ExtensionModel.Results.self, from: data)
        var extensions: [ExtensionModel.Card] = []

        for result in result.results {
            for ext in result.extensions {
                var extCard = ExtensionModel.Card(
                    displayName: ext.displayName,
                    releaseDate: ext.releaseDate,
                    shortDescription: ext.shortDescription,
                    verified: ext.flags.contains(.verified),
                    publisherName: ext.publisher.displayName
                )

                if let file = ext.versions.first?.files?
                    .first(where: { $0.assetType == .ServicesIconSmall })
                    ?? ext.versions.first?.files?
                    .first(where: { $0.assetType == .ServicesIconDefault })
                {
                    let data = try await getFile(ext: ext, file: file)
                    extCard.image = NSImage(data: data)
                }

                if let installs = ext.statistics?
                    .first(where: { (s: ExtensionModel.Statistics) -> Bool in
                        s.statisticName == .install
                    })?.value
                {
                    extCard.installs = installs.quantityString()
                }

                if let averagerating = ext.statistics?
                    .first(where: { $0.statisticName == .averagerating })?.value
                {
                    extCard.averagerating = averagerating.fixedString()
                }

                if let package = ext.versions.first?.files?
                    .first(where: { $0.assetType == .ServicesVSIXPackage })?.source
                {
                    var request = URLRequest(url: package)
                    request.httpMethod = "HEAD"

                    let (_, urlResponse) = try await URLSession.shared.data(for: request)
                    if let response = urlResponse as? HTTPURLResponse {
                        if let length = response.allHeaderFields["Content-Length"] as? String,
                           let size = UInt(length),
                           size != 93
                        {
                            extCard.packageSize = size.humanizedByteString()
                        }
                    }
                }

                extensions.append(extCard)
            }
        }

        return extensions
    }

    func getFeatured() async throws -> [ExtensionModel.Card] {
        return try await getExtensions(filter: .init(pageSize: 4,
                                                     criteria: [.init(filterType: .Featured)]))
    }

    func getPopular() async throws -> [ExtensionModel.Card] {
        return try await getExtensions(filter: .init(pageSize: 4,
                                                     criteria: [
                                                         .init(filterType: .ExcludeWithFlags),
                                                     ]))
    }

    func searchExtensions(_ search: String) async throws -> [ExtensionModel.Card] {
        return try await getExtensions(filter: .init(pageSize: 10,
                                                     criteria: [
                                                         .init(
                                                             filterType: .SearchText,
                                                             value: search
                                                         ),
                                                     ]))
    }
}
