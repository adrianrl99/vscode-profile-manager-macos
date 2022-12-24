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

    private func getFile(ext: ExtensionModel.Card, file: ExtensionModel.File) async throws -> Data {
        let base = (path + ext.extensionName + (ext.version ?? "unknown"))
        let cached = File<Data>(path: base + file.assetType.rawValue)
        if cached.exists, let data = try? cached.read() {
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
    ) async throws -> ([ExtensionModel.Card], UInt) {
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
        var result = try decoder.decode(ExtensionModel.Results.Card.self, from: data)
        var total: UInt = 0

        for r in 0 ..< result.results.count {
            let res = result.results[r]

            if let metTotal = res.resultMetadata
                .first(where: { $0.metadataType == .ResultCount })?.metadataItems
                .first(where: { $0.name == .TotalCount })?.count
            {
                total += metTotal
            }

            for e in 0 ..< res.extensions.count {
                let ext = res.extensions[e]

                if let image = ext.imageFile {
                    let data = try await getFile(ext: ext, file: image)
                    result.results[r].extensions[e].image = NSImage(data: data)
                }
            }
        }

        let extensions = result.results.flatMap { $0.extensions }

        return (extensions, total)
    }

    func getFeatured() async throws -> ([ExtensionModel.Card], UInt) {
        return try await getExtensions(filter: .init(pageSize: 4,
                                                     criteria: [.init(filterType: .Featured)]))
    }

    func getPopular() async throws -> ([ExtensionModel.Card], UInt) {
        return try await getExtensions(filter: .init(pageSize: 4,
                                                     criteria: [
                                                         .init(filterType: .ExcludeWithFlags),
                                                     ]))
    }

    func searchExtensions(_ search: String,
                          _ page: UInt?) async throws -> ([ExtensionModel.Card], UInt)
    {
        return try await getExtensions(filter: .init(pageNumber: page ?? 1, pageSize: 20,
                                                     criteria: [
                                                         .init(
                                                             filterType: .SearchText,
                                                             value: search
                                                         ),
                                                     ]))
    }

    func installExtension(_ ext: ExtensionModel.Card) async throws {
        _ = ext
//        let data = try await getFile(ext: ext, file: <#T##ExtensionModel.File#>)
    }
}
