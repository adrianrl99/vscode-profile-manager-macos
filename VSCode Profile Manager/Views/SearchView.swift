import SwiftUI

struct SearchView: View {
    @EnvironmentObject var services: Services
    @EnvironmentObject var gs: GlobalState
    @State var loading = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                SwiftUI.Section(header: SearchBar()) {
                    VStack(alignment: .leading, spacing: 20) {
                        if !loading && gs.extensionsSearchResult.isEmpty {
                            ESection("Featured", gs.extensionsFeatured)
                            ESection("Popular", gs.extensionsPopular)
                        } else {
                            ESection(nil, gs.extensionsSearchResult)
                        }
                    }
                }
            }
        }
        .task {
            do {
                if gs.extensionsFeatured.isEmpty {
                    gs.extensionsFeatured = try await services.extension.getFeatured()
                }

                if gs.extensionsPopular.isEmpty {
                    gs.extensionsPopular = try await services.extension.getPopular()
                }
            } catch {
                print(error)
            }
        }
    }

    private func handleSearch() {
        Task {
            gs.extensionsSearchResult = []
            loading = true
            do {
                if !gs.extensionsSearch.isEmpty {
                    gs.extensionsSearchResult = try await services.extension
                        .searchExtensions(gs.extensionsSearch)
                }
            } catch {
                print(error)
            }
            loading = false
        }
    }

    @ViewBuilder func SearchBar() -> some View {
        HStack {
            TextField("Search", text: $gs.extensionsSearch)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit(handleSearch)
            Button(action: handleSearch) {
                if loading {
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 15)

                } else {
                    Image(systemName: "magnifyingglass")
                }
            }
            .disabled(loading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .frame(width: 400)
        .background(Color.primary.opacity(0.05))
        .background(.thinMaterial)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    @ViewBuilder func ESection(_ title: String?, _ extensions: [ExtensionModel.Card]) -> some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .font(.title)
                    .bold()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))]) {
                if !extensions.isEmpty {
                    ForEach(extensions, id: \.self) { ext in
                        ExtensionCard(ext: ext)
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
        }
    }
}

#if DEBUG
    struct SearchView_Previews: PreviewProvider {
        static var previews: some View {
            SearchView()
                .padding()
                .environmentObject(GlobalState())
                .environmentObject(Services())
        }
    }
#endif
