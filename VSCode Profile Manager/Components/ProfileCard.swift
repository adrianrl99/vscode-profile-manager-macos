import SwiftUI

struct ProfileCard: View {
    @EnvironmentObject var services: Services

    let profile: ProfileModel
    let withCategory: Bool
    @State var confirmDelete: Bool = false

    var body: some View {
        Card {
            HStack {
                if let data = profile.image, let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: "viewfinder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }

                VStack(alignment: .leading) {
                    Text(profile.name)
                        .font(.title3)
                        .bold()

                    HStack {
                        Text("Extensions: \(profile.extensionsCount)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        if withCategory {
                            Text(profile.category.rawValue.lowercased())
                                .font(.caption)
                                .foregroundColor(.indigo)
                        }
                    }
                }

                Spacer(minLength: 0)

                Button("Open") {
                    if let profiles = services.profiles {
                        do {
                            try profiles.open(profile)
                            try services.syncProfiles([.recents])
                        } catch {
                            print(error)
                        }
                    }
                }

                Menu {
                    NavigationLink("Edit", destination: AddProfileView(profile: profile))

                    Button("Delete", role: .destructive) {
                        confirmDelete = true
                    }

                } label: {
                    Image(systemName: "ellipsis")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
            }
            .frame(maxWidth: .infinity)
            .alert(
                "Are you sure you want to remove the \(profile.name) profile?",
                isPresented: $confirmDelete
            ) {
                Button("OK", role: .destructive) {
                    if let profiles = services.profiles {
                        do {
                            try profiles.delete(profile)
                            try services.syncProfiles([.recents, .byCategory])
                        } catch {
                            print(error)
                        }
                    }
                    confirmDelete = false
                }
                Button("Cancel", role: .cancel) {
                    confirmDelete = false
                }
            }
        }
    }
}
