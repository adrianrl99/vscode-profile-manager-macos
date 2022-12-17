import SwiftUI

struct ProfilesView: View {
    var body: some View {
        Text("Profiles")
    }
}

#if DEBUG
    struct ProfilesView_Previews: PreviewProvider {
        static var previews: some View {
            ProfilesView()
        }
    }
#endif
