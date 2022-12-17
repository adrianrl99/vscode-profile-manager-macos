import SwiftUI

struct SettingsView: View {
    var body: some View {
        Text("Settings")
    }
}

#if DEBUG
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
#endif
