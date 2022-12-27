import SwiftUI

struct ExtensionsList: View {
    let withSearch: Bool
    let onSearch: ((String, UInt) async throws -> Void)?
    let selectable: Bool
    @Binding var selected: [Int64]
    @Binding var exts: [ExtensionModel]
    @Binding var total: UInt
    @State var loading = false
    @State var search = ""
    @State var page: UInt = 1

    init(_ exts: Binding<[ExtensionModel]>) {
        _exts = exts
        withSearch = false
        onSearch = nil
        selectable = false
        _total = Binding(get: { UInt(exts.count) }, set: { _ in })
        _selected = Binding(get: { [] }, set: { _ in })
    }

    init(_ exts: Binding<[ExtensionModel]>, _ selected: Binding<[Int64]>) {
        _exts = exts
        withSearch = false
        onSearch = nil
        selectable = true
        _total = Binding(get: { UInt(exts.count) }, set: { _ in })
        _selected = selected
    }

    init(
        _ exts: Binding<[ExtensionModel]>,
        _ selected: Binding<[Int64]>,
        _ total: Binding<UInt>,
        search: @escaping (String, UInt) async throws -> Void
    ) {
        _exts = exts
        withSearch = true
        onSearch = search
        selectable = true
        _total = total
        _selected = selected
    }

    var body: some View {
        VStack {
            if withSearch {
                SearchBar()
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach($exts, id: \.self) { ext in
                        if selectable {
                            ExtensionCard(ext: ext, selected: $selected)
                                .onAppear {
                                    if ext.wrappedValue == exts.last {
                                        handleSearch(true)
                                    }
                                }
                        } else {
                            ExtensionCard(ext: ext)
                                .onAppear {
                                    if ext.wrappedValue == exts.last {
                                        handleSearch(true)
                                    }
                                }
                        }
                    }

                    if loading {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
                }
            }
        }
        .onAppear {
            if withSearch {
                handleSearch()
            }
        }
        .onDisappear {
            exts = []
            search = ""
            page = 1
            total = 0
            loading = false
        }
    }

    @ViewBuilder func SearchBar() -> some View {
        HStack {
            TextField("Search", text: $search)
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
        .background(Color.primary.opacity(0.05))
        .background(.thinMaterial)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    func handleSearch(_ more: Bool = false) {
        if (!loading || exts.count >= total) && withSearch {
            if more {
                page += 1
            } else {
                exts = []
                page = 1
            }
            Task {
                loading = true
                do {
                    try await onSearch?(search, page)
                } catch {
                    print(error)
                }
                loading = false
            }
        }
    }
}
