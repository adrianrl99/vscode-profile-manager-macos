import SwiftUI

struct ExtensionsView: View {
    @EnvironmentObject var services: Services
    @State var exts: [ExtensionModel] = []

    var body: some View {
        ExtensionsList($exts)
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
