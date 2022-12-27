import AppKit
import Foundation

struct ProfileModel: Identifiable, Hashable {
    let id: Int64
    var name: String
    var category: Category
    var image: Data? = nil
    var used: Date?
    let extensionsCount: UInt
    var extensions: [ExtensionModel] = []

    enum Category: String, Hashable, CaseIterable {
        case language
        case framework
        case project
        case other
    }
}
