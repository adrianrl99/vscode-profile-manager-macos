import FileKit
import SwiftUI

extension AddProfileView {
    enum TabType: String, CaseIterable {
        case installed
        case search
    }
}

struct AddProfileView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @EnvironmentObject var services: Services

    @State var name: String = ""
    @State var category: ProfileModel.Category = .other
    @State var tab: TabType = .installed
    @State var image: Data? = nil
    var profile: ProfileModel? = nil

    var body: some View {
        Layout("Add Profile") {
            VStack {
                VStack {
                    HStack(spacing: 15) {
                        Button {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            panel.allowedContentTypes = [.image]
                            if panel.runModal() == .OK, let url = panel.url {
                                let file = File<Data>(path: Path(url: url)!)
                                image = try? file.read()
                            }
                        } label: {
                            if let image, let nsImage = NSImage(data: image) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "viewfinder")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 70, height: 70)
                        .buttonStyle(.plain)

                        VStack(spacing: 15) {
                            TextField("Name", text: $name)
                                .font(.title2)

                            Picker("Category", selection: $category) {
                                ForEach(ProfileModel.Category.allCases, id: \.self) { category in
                                    Text(category.rawValue.capitalized)
                                }
                            }
                            .labelsHidden()
                        }
                    }
                }
                .padding(.horizontal, 10)

                Divider()

                HStack(spacing: 2) {
                    ForEach(TabType.allCases, id: \.self) { tab in
                        TabButton(
                            title: tab.rawValue.capitalized,
                            tab: tab,
                            selected: $tab
                        )
                    }
                }
                .padding(.horizontal, 10)

                HStack {
                    switch tab {
                    case .installed: ExtensionsView()
                    case .search: ExtensionsView()
                    }
                }
                .padding(10)
            }
        } actions: {
            Button("Done") {
                do {
                    if let profiles = services.profiles {
                        if var profile {
                            profile.name = name
                            profile.category = category
                            profile.image = image
                            try profiles.update(profile)
                            try services.syncProfiles([.recents, .byCategory])
                        } else {
                            let profile = try profiles.create(
                                name: name,
                                category: category,
                                image: image
                            )
                            try services.syncProfiles([.byCategory])
                        }
                    }
                    dismiss()

                } catch {
                    print(error)
                }
            }
            .disabled(name.isEmpty || image == nil)
        }
        .onAppear {
            if let profile = profile {
                name = profile.name
                category = profile.category
                image = profile.image
            }
        }
    }
}

#if DEBUG
    struct AddProfileView_Previews: PreviewProvider {
        static var previews: some View {
            AddProfileView()
                .environmentObject(Services())
        }
    }
#endif
