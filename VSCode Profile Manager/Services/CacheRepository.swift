import FileKit
import Foundation

struct CacheRepository {
    let profiles: Profiles
    let extensions: Extensions

    init(base: Path) throws {
        profiles = try Profiles(base: base)
        extensions = try Extensions(base: base)
    }

    struct Extensions {
        let path: Path

        init(base: Path) throws {
            path = base + "extensions"

            if !path.exists {
                try! base.createDirectory(withIntermediateDirectories: true)
            }
        }

        func save(_ ext: ExtensionModel) throws {
            let cache = path + ext.extensionName + (ext.version ?? "")
            if !cache.exists {
                try cache.createDirectory(withIntermediateDirectories: true)
            }

            let imageFile = File<Data>(path: cache + "image")
            if let image = ext.image {
                try image |> imageFile
            }
        }

        func saveVsix(_ ext: ExtensionModel, _ data: Data) throws {
            let cache = path + ext.extensionName + (ext.version ?? "")

            let vsixFile = File<Data>(path: cache + "vsix")
            try data |> vsixFile
        }

        func read(_ ext: ExtensionModel) throws -> ExtensionModel {
            var ext = ext
            let cache = path + ext.extensionName + (ext.version ?? "")

            let imageFile = File<Data>(path: cache + "image")
            if let image = try? imageFile.read() {
                ext.image = image
            }

            return ext
        }
    }

    struct Profiles {
        let path: Path
        let extsPath: Path

        init(base: Path) throws {
            path = base + "profiles"
            extsPath = base + "extensions"

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

        func vsixPath(_ ext: ExtensionModel) throws -> Path {
            extsPath + ext.extensionName + (ext.version ?? "") + "vsix"
        }
    }
}
