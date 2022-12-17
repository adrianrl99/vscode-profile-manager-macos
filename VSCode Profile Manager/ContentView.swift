import SwiftUI

enum TabType: Equatable {
    case profile
    case extensions
    case search
    case settings
}

final class GlobalState: ObservableObject {
    @Published var selectedTab: TabType = .profile
    @Published var extensionsFeatured: [ExtensionModel.Card] = []
    @Published var extensionsPopular: [ExtensionModel.Card] = []
    @Published var extensionsSearchResult: [ExtensionModel.Card] = []
    @Published var extensionsSearch: String = ""
}

struct ContentView: View {
    @StateObject var gs = GlobalState()
    @StateObject var services = Services()

    var body: some View {
        HStack(spacing: 0) {
            SideBar()

            Divider()

            HStack {
                VStack(alignment: .leading) {
                    switch gs.selectedTab {
                    case .profile: ProfilesView()
                    case .extensions: ExtensionsView()
                    case .search: SearchView()
                    case .settings: SettingsView()
                    }

                    Spacer()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .all)
        .environmentObject(gs)
        .environmentObject(services)
    }
}

#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
#endif
