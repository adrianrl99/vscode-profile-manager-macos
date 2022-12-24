import FileKit
import Foundation

struct CacheRepository {
    let profiles: Profiles

    init(base: Path) throws {
        profiles = try Profiles(base: base)
    }

    struct Profiles {
        let path: Path

        init(base: Path) throws {
            path = base + "profiles"
            print("Profiles: \(path)")

            if !path.exists {
                try! base.createDirectory(withIntermediateDirectories: true)
            }
        }

        func save(_ profile: ProfileModel) throws {
            let cache = path + profile.category.rawValue + profile.name
            if !cache.exists {
                try cache.createDirectory(withIntermediateDirectories: true)
            }

            let imageFile = File<Data>(path: cache + "image")
            if let image = profile.image {
                try image |> imageFile
            }

            let data = cache + "data"
            if !data.exists {
                try data.createDirectory()
            }
            let exts = cache + "exts"
            if !exts.exists {
                try exts.createDirectory()
            }
        }

        func clear(_ profile: ProfileModel) throws {
            let cache = path + profile.category.rawValue + profile.name
            if cache.exists {
                try cache.deleteFile()
            }
        }

        func read(_ profile: ProfileModel) throws -> ProfileModel {
            var profile = profile
            let cache = path + profile.category.rawValue + profile.name

            let imageFile = File<Data>(path: cache + "image")
            if let image = try? imageFile.read() {
                profile.image = image
            }

            return profile
        }

        func paths(_ profile: ProfileModel) -> (Path, Path) {
            let cache = path + profile.category.rawValue + profile.name
            return (cache + "data", cache + "path")
        }
    }
}
