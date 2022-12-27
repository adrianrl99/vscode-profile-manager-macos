import FileKit
import Foundation

struct ExtensionsRepository {
    private let db: DatabaseRepository.Extensions
    private let cache: CacheRepository.Extensions
    private let api: ApiRepository.Extensions

    init(
        db: DatabaseRepository.Extensions,
        cache: CacheRepository.Extensions,
        api: ApiRepository.Extensions
    ) {
        self.db = db
        self.cache = cache
        self.api = api
    }

    private func readOrSave(_ extensions: [ExtensionModel]) async throws -> [ExtensionModel] {
        var extensions = extensions
        for i in 0 ..< extensions.count {
            var ext = try cache.read(extensions[i])

            if ext.image == nil, let url = ext.imageURL {
                let request = URLRequest(url: url)
                let (data, _) = try await URLSession.shared.data(for: request)
                ext.image = data
                try cache.save(ext)
            }

            extensions[i] = ext
        }

        return extensions
    }

    @discardableResult
    func create(_ ext: ExtensionModel) throws -> ExtensionModel {
        let ext = try db.create(ext)
        try cache.save(ext)
        return ext
    }

    func search(_ search: String, _ page: UInt?) async throws -> ([ExtensionModel], UInt) {
        var criteria: [ExtensionModel.Filter.Criterium] = []

        if !search.isEmpty {
            criteria.append(.init(filterType: .SearchText, value: search))
        }

        let filter = ExtensionModel.Filter(
            pageNumber: page ?? 1,
            pageSize: 20,
            criteria: criteria
        )

        // Pre search extensions to prevent get cached extensions
        let (preSearch, total) = try await api.preSearch(filter: filter)
        let ids = preSearch.map { $0.extensionId }
        let cachedExtensions = try db.readByIDs(ids)
        let uncachedIDs = ids
            .filter { id in !cachedExtensions.contains(where: { $0.extensionId == id }) }

        print(filter)
        // Search uncached extensions and cache it
        let uncached = try (uncachedIDs.isEmpty
            ? []
            : try await api.search(filter: .init(
                pageNumber: 1,
                pageSize: UInt(uncachedIDs.count),
                criteria: uncachedIDs
                    .map { .init(filterType: .ExtensionId, value: $0.uuidString) }
            ))).map(db.create)

        // Pack cached and uncached extensions with the pre-search order
        var extensions = uncached.isEmpty
            ? cachedExtensions
            : preSearch.map { ext in
                cachedExtensions.first(where: { $0.extensionId == ext.extensionId })
                    ?? uncached.first(where: { $0.extensionId == ext.extensionId })
                    ?? ext
            }.filter { $0.id != nil }

        extensions = try await readOrSave(extensions)

        return (extensions, total)
    }

    func installed() async throws -> [ExtensionModel] {
        var extensions = try db.readInstalled()
        extensions = try await readOrSave(extensions)
        return extensions
    }

    func install(_ ext: ExtensionModel) async throws -> ExtensionModel {
        var ext = ext

        if let url = ext.vsixURL {
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            try cache.saveVsix(ext, data)
            ext.installed = true
            try db.update(ext)
        }

        return ext
    }
}
