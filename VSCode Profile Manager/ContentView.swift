import SwiftUI

extension ContentView {
    enum TabType: String, CaseIterable {
        case profile
        case extensions
    }
}

struct ContentView: View {
    @StateObject var gs = GlobalState()
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
                                selected: $gs.selectedTab
                            )
                        }
                    }

                    HStack {
                        switch gs.selectedTab {
                        case .profile: ProfilesView()
                        case .extensions: ExtensionsView()
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
