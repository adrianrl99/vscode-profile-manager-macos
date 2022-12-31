import FileKit
import Foundation
import SQLite
import SwiftDate

struct DatabaseRepository {
    let profiles: Profiles
    let extensions: Extensions

    init(base: Path) throws {
        let path = base + "database.sqlite"

        let ctx = Context(
            db: try Connection(path.rawValue),
            pt: Table("profiles"),
            et: Table("extensions"),
            pet: Table("profiles_extensions")
        )

        try ProfilesExtensions(ctx: ctx)
        profiles = try Profiles(ctx: ctx)
        extensions = try Extensions(ctx: ctx)
    }

    struct Context {
        let db: Connection
        let pt: Table
        let et: Table
        let pet: Table
    }

    struct Extensions {
        private let ctx: Context

        enum Fields {
            static let id = Expression<Int64>("id")

            static let extensionId = Expression<UUID>("extension_id")
            static let extensionName = Expression<String>("extension_name")
            static let displayName = Expression<String>("display_name")
            static let lastUpdated = Expression<Date>("last_updated")
            static let shortDescription = Expression<String?>("short_description")
            static let verified = Expression<Bool>("verified")
            static let publisherName = Expression<String>("publisher_name")

            static let installed = Expression<Bool>("installed")
            static let version = Expression<String?>("version")
            static let imageURL = Expression<URL?>("image_url")
            static let vsixURL = Expression<URL?>("vsix_url")
            static let installs = Expression<String?>("installs")
            static let averagerating = Expression<String?>("averagerating")
        }

        init(ctx: Context) throws {
            self.ctx = ctx

            try ctx.db.run(ctx.et.create(ifNotExists: true) { t in
                t.column(Fields.id, primaryKey: .autoincrement)
                t.column(Fields.extensionId)
                t.column(Fields.extensionName)
                t.column(Fields.displayName)
                t.column(Fields.lastUpdated)
                t.column(Fields.shortDescription)
                t.column(Fields.verified)
                t.column(Fields.publisherName)
                t.column(Fields.installed)
                t.column(Fields.version)
                t.column(Fields.imageURL)
                t.column(Fields.vsixURL)
                t.column(Fields.installs)
                t.column(Fields.averagerating)
            })
        }

        func create(_ ext: ExtensionModel) throws -> ExtensionModel {
            var ext = ext
            ext.id = try ctx.db.run(ctx.et.insert(
                Fields.extensionId <- ext.extensionId,
                Fields.extensionName <- ext.extensionName,
                Fields.displayName <- ext.displayName,
                Fields.lastUpdated <- ext.lastUpdated.date,
                Fields.shortDescription <- ext.shortDescription,
                Fields.verified <- ext.verified,
                Fields.publisherName <- ext.publisherName,
                Fields.installed <- ext.installed,
                Fields.version <- ext.version,
                Fields.imageURL <- ext.imageURL,
                Fields.vsixURL <- ext.vsixURL,
                Fields.installs <- ext.installs,
                Fields.averagerating <- ext.averagerating
            ))
            return ext
        }

        func readByIDs(_ ids: [UUID]) throws -> [ExtensionModel] {
            try ctx.db.prepare(ctx.et.filter(ids.contains(Fields.extensionId))).map {
                ExtensionModel(
                    id: $0[Fields.id],
                    extensionId: $0[Fields.extensionId],
                    extensionName: $0[Fields.extensionName],
                    displayName: $0[Fields.displayName],
                    lastUpdated: $0[Fields.lastUpdated].inDefaultRegion(),
                    shortDescription: $0[Fields.shortDescription],
                    verified: $0[Fields.verified],
                    publisherName: $0[Fields.publisherName],
                    installed: $0[Fields.installed],
                    version: $0[Fields.version],
                    imageURL: $0[Fields.imageURL],
                    vsixURL: $0[Fields.vsixURL],
                    installs: $0[Fields.installs],
                    averagerating: $0[Fields.averagerating]
                )
            }
        }

        func readInstalled() throws -> [ExtensionModel] {
            try ctx.db.prepare(ctx.et.where(Fields.installed == true).order(Fields.displayName))
                .map {
                    ExtensionModel(
                        id: $0[Fields.id],
                        extensionId: $0[Fields.extensionId],
                        extensionName: $0[Fields.extensionName],
                        displayName: $0[Fields.displayName],
                        lastUpdated: $0[Fields.lastUpdated].inDefaultRegion(),
                        shortDescription: $0[Fields.shortDescription],
                        verified: $0[Fields.verified],
                        publisherName: $0[Fields.publisherName],
                        installed: $0[Fields.installed],
                        version: $0[Fields.version],
                        imageURL: $0[Fields.imageURL],
                        vsixURL: $0[Fields.vsixURL],
                        installs: $0[Fields.installs],
                        averagerating: $0[Fields.averagerating]
                    )
                }
        }

        func update(_ ext: ExtensionModel) throws {
            if let id = ext.id {
                try ctx.db.run(ctx.et.where(Fields.id == id).update(
                    Fields.extensionId <- ext.extensionId,
                    Fields.extensionName <- ext.extensionName,
                    Fields.displayName <- ext.displayName,
                    Fields.lastUpdated <- ext.lastUpdated.date,
                    Fields.shortDescription <- ext.shortDescription,
                    Fields.verified <- ext.verified,
                    Fields.publisherName <- ext.publisherName,
                    Fields.installed <- ext.installed,
                    Fields.version <- ext.version,
                    Fields.imageURL <- ext.imageURL,
                    Fields.vsixURL <- ext.vsixURL,
                    Fields.installs <- ext.installs,
                    Fields.averagerating <- ext.averagerating
                ))
            }
        }
    }

    struct ProfilesExtensions {
        enum Fields {
            static let id = Expression<Int64>("id")
            static let profile_id = Expression<Int64>("profile_id")
            static let extension_id = Expression<Int64>("extension_id")
        }

        @discardableResult
        init(ctx: Context) throws {
            try ctx.db.run(ctx.pet.create(ifNotExists: true) { t in
                t.column(Fields.id, primaryKey: .autoincrement)
                t.column(Fields.profile_id, references: ctx.pt, Fields.id)
                t.column(Fields.extension_id, references: ctx.et, Fields.id)
            })
        }
    }

    struct Profiles {
        private let ctx: Context

        enum Fields {
            static let id = Expression<Int64>("id")
            static let name = Expression<String>("name")
            static let category = Expression<String>("category")
            static let used = Expression<Date?>("used")
        }

        init(ctx: Context) throws {
            self.ctx = ctx

            try ctx.db.run(ctx.pt.create(ifNotExists: true) { t in
                t.column(Fields.id, primaryKey: .autoincrement)
                t.column(Fields.name, unique: true)
                t.column(Fields.category)
                t.column(Fields.used)
            })
        }

        @discardableResult
        func create(name: String, category: ProfileModel.Category,
                    exts: [Int64]) throws -> ProfileModel
        {
            let id = try ctx.db.run(ctx.pt.insert(
                Fields.name <- name,
                Fields.category <- category.rawValue,
                Fields.used <- nil
            ))
            try ctx.db.run(ctx.pet.insertMany(
                exts.map { [
                    ProfilesExtensions.Fields.profile_id <- id,
                    ProfilesExtensions.Fields.extension_id <- $0,
                ] }
            ))
            return ProfileModel(
                id: id,
                name: name,
                category: category,
                used: nil,
                extensionsCount: 0
            )
        }

        func readRecents() throws -> [ProfileModel] {
            try ctx.db.prepare(ctx.pt.where(Fields.used != nil).order(Fields.used.desc).limit(4))
                .map {
                    let id = $0[Fields.id]
                    return ProfileModel(
                        id: id,
                        name: $0[Fields.name],
                        category: .init(rawValue: $0[Fields.category]) ?? .other,
                        used: $0[Fields.used],
                        extensionsCount: try UInt(ctx.db.scalar(
                            ctx.pet.where(ProfilesExtensions.Fields.profile_id == id).count
                        ))
                    )
                }
        }

        func readByCategory() throws -> [ProfileModel.Category: [ProfileModel]] {
            var profiles: [ProfileModel.Category: [ProfileModel]] = [:]
            for row in try ctx.db.prepare(ctx.pt.order(Fields.name)) {
                let id = row[Fields.id]
                let profile = ProfileModel(
                    id: id,
                    name: row[Fields.name],
                    category: .init(rawValue: row[Fields.category]) ?? .other,
                    used: row[Fields.used],
                    extensionsCount: try UInt(ctx.db.scalar(
                        ctx.pet.where(ProfilesExtensions.Fields.profile_id == id).count
                    ))
                )

                if profiles[profile.category] == nil {
                    profiles[profile.category] = []
                }
                profiles[profile.category]!.append(profile)
            }

            return profiles
        }

        func setExtensions(_ profile: ProfileModel) throws -> ProfileModel {
            var profile = profile

            profile.extensions = try ctx.db.prepare(
                ctx.et.join(
                    ctx.pet,
                    on: Fields.id == ctx.pet[ProfilesExtensions.Fields.extension_id]
                ).where(ProfilesExtensions.Fields.profile_id == profile.id)
            ).map {
                ExtensionModel(
                    id: $0[Extensions.Fields.id],
                    extensionId: $0[Extensions.Fields.extensionId],
                    extensionName: $0[Extensions.Fields.extensionName],
                    displayName: $0[Extensions.Fields.displayName],
                    lastUpdated: $0[Extensions.Fields.lastUpdated].inDefaultRegion(),
                    shortDescription: $0[Extensions.Fields.shortDescription],
                    verified: $0[Extensions.Fields.verified],
                    publisherName: $0[Extensions.Fields.publisherName],
                    installed: $0[Extensions.Fields.installed],
                    version: $0[Extensions.Fields.version],
                    imageURL: $0[Extensions.Fields.imageURL],
                    vsixURL: $0[Extensions.Fields.vsixURL],
                    installs: $0[Extensions.Fields.installs],
                    averagerating: $0[Extensions.Fields.averagerating]
                )
            }

            return profile
        }

        func readExtensionsIDs(_ profile: ProfileModel) throws -> [Int64] {
            try ctx.db.prepare(
                ctx.pet.where(ProfilesExtensions.Fields.profile_id == profile.id)
            ).map { $0[ProfilesExtensions.Fields.extension_id] }
        }

        func update(_ profile: ProfileModel) throws {
            try ctx.db.run(ctx.pt.where(Fields.id == profile.id).update(
                Fields.name <- profile.name,
                Fields.category <- profile.category.rawValue,
                Fields.used <- profile.used
            ))

            var deletes = try ctx.db.prepare(
                ctx.pet.where(ProfilesExtensions.Fields.profile_id == profile.id)
            ).map { ($0[ProfilesExtensions.Fields.id], $0[ProfilesExtensions.Fields.extension_id]) }

            var inserts: [Int64] = []
            var updates: [(Int64, Int64)] = []

            for ext in profile.extensions {
                guard let id = ext.id else { continue }

                if let idx = deletes.firstIndex(where: { $0.1 == id }) {
                    updates.append(deletes.remove(at: idx))
                } else {
                    inserts.append(id)
                }
            }

            // Insert
            try ctx.db.run(ctx.pet.insertMany(
                inserts.map { [
                    ProfilesExtensions.Fields.profile_id <- profile.id,
                    ProfilesExtensions.Fields.extension_id <- $0,
                ] }
            ))

            // Update
            for ext in updates {
                try ctx.db.run(ctx.pet.where(ProfilesExtensions.Fields.id == ext.0)
                    .update(ProfilesExtensions.Fields.id <- ext.1))
            }

            // Delete
            for ext in deletes {
                try ctx.db.run(ctx.pet.where(ProfilesExtensions.Fields.id == ext.0).delete())
            }
        }

        func delete(_ profile: ProfileModel) throws {
            try ctx.db.run(ctx.pt.where(Fields.id == profile.id).delete())

            try ctx.db
                .run(ctx.pet.where(ProfilesExtensions.Fields.profile_id == profile.id).delete())
        }
    }
}
