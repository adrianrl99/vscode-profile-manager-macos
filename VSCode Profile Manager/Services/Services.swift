import FileKit
import Foundation

final class Services: ObservableObject {
    let profiles: ProfilesRepository?
    let extensions: ExtensionsRepository?

    @Published var profilesRecents: [ProfileModel] = []
    @Published var profilesByCategory: [ProfileModel.Category: [ProfileModel]] = [:]

    init() {
        let base = Path.userHome + ".Vscode Profile Manager"
        if !base.exists {
            try! base.createDirectory(withIntermediateDirectories: true)
        }

        guard let db = try? DatabaseRepository(base: base),
              let cache = try? CacheRepository(base: base)
        else {
            profiles = nil
            extensions = nil
            return
        }
        let api = ApiRepository()

        profiles = ProfilesRepository(db: db.profiles, cache: cache.profiles)
        extensions = ExtensionsRepository(
            db: db.extensions,
            cache: cache.extensions,
            api: api.extensions
        )
    }

    enum ProfilesSyncType {
        case recents
        case byCategory
    }

    func syncProfiles(_ types: [ProfilesSyncType]) throws {
        if let profiles = profiles {
            if types.contains(.recents) {
                profilesRecents = try profiles.readRecents()
            }

            if types.contains(.byCategory) {
                profilesByCategory = try profiles.readByCategory()
            }
        }
    }
}
