import Foundation

struct ApiRepository {
    let extensions: Extensions

    init() {
        extensions = Extensions()
    }

    struct Extensions {
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

        private func getResults(_ filters: ExtensionModel
            .Filters) async throws -> [ExtensionModel.Results.Result]
        {
            let encoder = JSONEncoder()
            let body = try! encoder.encode(filters)

            var request = self.request
            request.httpBody = body
            let (data, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(ExtensionModel.Results.self, from: data)
                return result.results
            } catch {
                let error = try decoder.decode(ExtensionModel.Results.Error.self, from: data)
                print(error)
                return []
            }
        }

        func preSearch(filter: ExtensionModel.Filter) async throws -> ([ExtensionModel], UInt) {
            let filters = ExtensionModel.Filters(flags: [.IncludeLatestVersionOnly], filters: [filter])

            let results = try await getResults(filters)

            return results.reduce(([], 0)) {
                ($0.0 + $1.extensions,
                 $0.1 + ($1.resultMetadata
                     .first(where: { $0.metadataType == .ResultCount })?.metadataItems
                     .first(where: { $0.name == .TotalCount })?.count ?? 0))
            }
        }

        func search(filter: ExtensionModel.Filter,
                    flags: [ExtensionModel.Filters.FlagType] = []) async throws -> [ExtensionModel]
        {
            let filters = ExtensionModel.Filters(
                flags: [.IncludeLatestVersionOnly, .IncludeStatistics, .IncludeFiles] + flags,
                filters: [filter]
            )

            let results = try await getResults(filters)

            return results.flatMap { $0.extensions }
        }
    }
}
