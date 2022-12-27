import SwiftUI

struct ExtensionsView: View {
    @Binding var exts: [ExtensionModel]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach($exts, id: \.self) {
                    ExtensionCard(ext: $0)
                }
            }
        }
    }
}

#if DEBUG
    struct ExtensionsView_Previews: PreviewProvider {
        static var previews: some View {
            ExtensionsView(exts: .constant([]))
                .frame(width: 320, height: 600)
                .padding(10)
        }
    }
#endif
