import Foundation

struct ProfilesRepository {
    private let db: DatabaseRepository.Profiles
    private let cache: CacheRepository.Profiles

    init(db: DatabaseRepository.Profiles, cache: CacheRepository.Profiles) {
        self.db = db
        self.cache = cache
    }

    @discardableResult
    private func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/local/bin/code"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }

    @discardableResult
    func create(name: String,
                category: ProfileModel.Category,
                image: Data?,
                exts: [Int64]) throws -> ProfileModel
    {
        var profile = try db.create(name: name, category: category, exts: exts)
        profile.image = image
        try cache.save(profile)

        return profile
    }

    func readRecents() throws -> [ProfileModel] {
        try db.readRecents().map(cache.read)
    }

    func readByCategory() throws -> [ProfileModel.Category: [ProfileModel]] {
        try db.readByCategory().mapValues { try $0.map(cache.read) }
    }

    func readExtensionsIDs(_ profile: ProfileModel) throws -> [Int64] {
        try db.readExtensionsIDs(profile)
    }

    func update(_ profile: ProfileModel, _ exts: [Int64]) throws {
        try db.update(profile, exts)
        try cache.save(profile)
    }

    func delete(_ profile: ProfileModel) throws {
        try db.delete(profile)
        try cache.clear(profile)
    }

    func open(_ profile: ProfileModel) throws {
        try db.updateUsed(profile)
        let (data, exts) = cache.paths(profile)
        shell("--extensions-dir", exts.rawValue, "--user-data-dir", data.rawValue)
    }
}
