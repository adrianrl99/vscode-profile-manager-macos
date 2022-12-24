import SwiftUI

@main
struct VSCode_Profile_ManagerApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Image(systemName: "viewfinder")
        }
        .menuBarExtraStyle(.window)
    }
}
