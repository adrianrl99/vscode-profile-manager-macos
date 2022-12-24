import Foundation

final class GlobalState: ObservableObject {
    @Published var selectedTab: ContentView.TabType = .profile
    @Published var extensionsFeatured: [ExtensionModel.Card] = []
    @Published var extensionsPopular: [ExtensionModel.Card] = []
    @Published var extensionsSearchResult: [ExtensionModel.Card] = []
    @Published var extensionsSearchResultTotal: UInt = 0
    @Published var extensionsSearch: String = ""

    init() {}
}
