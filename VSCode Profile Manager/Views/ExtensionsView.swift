import SwiftUI

struct ExtensionsView: View {
    var body: some View {
        Text("Extensions")
    }
}

#if DEBUG
    struct ExtensionsView_Previews: PreviewProvider {
        static var previews: some View {
            ExtensionsView()
        }
    }
#endif
