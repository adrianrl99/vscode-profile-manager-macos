import FileKit
import Foundation
import SQLite

struct DatabaseRepository {
    let profiles: Profiles

    init(base: Path) throws {
        let path = base + "database.sqlite"
        print("Database: \(path)")

        let db = try Connection(path.rawValue)
        profiles = try Profiles(db: db)
    }

    struct Profiles {
        private let db: Connection
        private let table: Table

        private let id = Expression<Int64>("id")
        private let name = Expression<String>("name")
        private let category = Expression<String>("category")
        private let used = Expression<Date?>("used")

        init(db: Connection) throws {
            self.db = db

            table = Table("profiles")

            try db.run(table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name, unique: true)
                t.column(category)
                t.column(used)
            })
        }

        @discardableResult
        func create(name: String, category: ProfileModel.Category) throws -> ProfileModel {
            ProfileModel(
                id: try db.run(table.insert(
                    self.name <- name,
                    self.category <- category.rawValue,
                    used <- nil
                )),
                name: name,
                category: category,
                used: nil
            )
        }

        func readRecents() throws -> [ProfileModel] {
            try db.prepare(table.where(used != nil).order(used.desc).limit(4)).map {
                ProfileModel(
                    id: $0[id],
                    name: $0[name],
                    category: .init(rawValue: $0[category]) ?? .other,
                    used: $0[used]
                )
            }
        }

        func readByCategory() throws -> [ProfileModel.Category: [ProfileModel]] {
            var profiles: [ProfileModel.Category: [ProfileModel]] = [:]
            for row in try db.prepare(table.order(name)) {
                let profile = ProfileModel(
                    id: row[id],
                    name: row[name],
                    category: .init(rawValue: row[category]) ?? .other,
                    used: row[used]
                )

                if profiles[profile.category] == nil {
                    profiles[profile.category] = []
                }
                profiles[profile.category]!.append(profile)
            }

            return profiles
        }

        func update(_ profile: ProfileModel) throws {
            try db.run(table.where(id == profile.id).update(
                name <- profile.name,
                category <- profile.category.rawValue,
                used <- profile.used
            ))
        }

        func delete(_ profile: ProfileModel) throws {
            try db.run(table.where(id == profile.id).delete())
        }
    }
}
