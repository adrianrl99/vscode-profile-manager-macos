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
                            ExtensionsList(
                                title: "Featured",
                                extensions: $gs.extensionsFeatured,
                                loadMore: {}
                            )
                            ExtensionsList(
                                title: "Popular",
                                extensions: $gs.extensionsPopular,
                                loadMore: {}
                            )
                        } else {
                            ExtensionsList(
                                title: nil,
                                extensions: $gs.extensionsSearchResult,
                                loadMore: { handleSearch(true) }
                            )
                        }
                    }
                }
            }
        }
        .padding(.top)
        .onAppear {
            if gs.extensionsFeatured.isEmpty {
                Task {
                    do {
                        let (extensions, _) = try await services.extension.getFeatured()
                        gs.extensionsFeatured = extensions
                    } catch {
                        print(error)
                    }
                }
            }

            if gs.extensionsPopular.isEmpty {
                Task {
                    do {
                        let (extensions, _) = try await services.extension.getPopular()
                        gs.extensionsPopular = extensions
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }

    private func handleSearch(_ more: Bool = false) {
        if gs.extensionsSearch.isEmpty {
            gs.extensionsSearchResult = []
            gs.extensionsSearchResultTotal = 0

            return
        }

        if loading ||
            (more && gs.extensionsSearchResult.count == gs.extensionsSearchResultTotal)
        {
            return
        }

        if !more {
            gs.extensionsSearchResult = []
            gs.extensionsSearchResultTotal = 0

            if gs.extensionsSearch.isEmpty {
                return
            }
        }
        loading = true

        var page: UInt?

        if gs.extensionsSearchResult.count % 20 == 0 {
            page = UInt((gs.extensionsSearchResult.count / 20) + 1)
        }

        Task {
            do {
                let (extensions, total) = try await services.extension
                    .searchExtensions(
                        gs.extensionsSearch,
                        page
                    )

                gs.extensionsSearchResult += extensions
                gs.extensionsSearchResultTotal = total

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
                .onSubmit { handleSearch() }
            Button { handleSearch() } label: {
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
