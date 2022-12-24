import SwiftUI

struct ExtensionsList: View {
    let title: String?
    @Binding var extensions: [ExtensionModel.Card]
    let loadMore: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .font(.title)
                    .bold()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))]) {
                if !extensions.isEmpty {
                    ForEach($extensions, id: \.self) { ext in
                        ExtensionCard(ext: ext)
                            .onAppear {
                                if ext.wrappedValue == extensions.last {
                                    loadMore()
                                }
                            }
                    }
                } else {
                    ForEach(0 ... 3, id: \.self) { _ in
                        Card {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            }
            .padding(.bottom)
        }
    }
}
