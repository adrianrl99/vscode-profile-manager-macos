import SwiftUI

struct SideBar: View {
    @EnvironmentObject var gs: GlobalState

    var body: some View {
        VStack(alignment: .leading) {
            TabButton(
                image: "viewfinder",
                title: "Profiles",
                tab: TabType.profile,
                selected: $gs.selectedTab
            )
            TabButton(
                image: "puzzlepiece.extension",
                title: "Extensions",
                tab: TabType.extensions,
                selected: $gs.selectedTab
            )
            TabButton(
                image: "magnifyingglass",
                title: "Search",
                tab: TabType.search,
                selected: $gs.selectedTab
            )

            Spacer()

            TabButton(
                image: "gear",
                title: "Settings",
                tab: TabType.settings,
                selected: $gs.selectedTab
            )
        }
        .padding()
        .padding(.top)
        .background(BlurWindow())
    }
}

#if DEBUG
    struct SideBar_Previews: PreviewProvider {
        static var previews: some View {
            SideBar()
                .background(BlurWindow())
                .ignoresSafeArea(.all, edges: .all)
                .environmentObject(GlobalState())
        }
    }
#endif
