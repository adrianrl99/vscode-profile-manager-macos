import SwiftUI

extension ContentView {
    enum TabType: String, CaseIterable {
        case profile
        case extensions
    }
}

struct ContentView: View {
    @State var selectedTab: TabType = .profile
    @StateObject var services = Services()

    var body: some View {
        NavigationStack {
            Layout("VSCode Profile Manager") {
                VStack(spacing: 10) {
                    HStack(spacing: 2) {
                        ForEach(TabType.allCases, id: \.self) { tab in
                            TabButton(
                                title: tab.rawValue.capitalized,
                                tab: tab,
                                selected: $selectedTab
                            )
                        }
                    }

                    HStack {
                        switch selectedTab {
                        case .profile: ProfilesView()
                        case .extensions: ExtensionsList(.constant([]))
                        }
                    }
                }
                .padding(.horizontal, 10)
            } actions: {
                NavigationLink(destination: AddProfileView()) {
                    Image(systemName: "plus")
                }

                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
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
