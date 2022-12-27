import SwiftUI

struct ExtensionsView: View {
    @EnvironmentObject var services: Services
    @State var exts: [ExtensionModel] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach($exts, id: \.self) {
                    ExtensionCard(ext: $0)
                }
            }
        }
        .onAppear {
            Task {
                do {
                    if let extensions = services.extensions {
                        exts = try await extensions.installed()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}
