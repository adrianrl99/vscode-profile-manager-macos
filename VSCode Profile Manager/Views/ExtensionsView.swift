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
                .frame(width: 320, height: 600)
                .padding(10)
        }
    }
#endif
