import SwiftUI

struct ProfilesView: View {
    @EnvironmentObject var services: Services

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !services.profilesRecents.isEmpty {
                    ProfileList(
                        title: "Recents",
                        profiles: services.profilesRecents,
                        withCategory: true
                    )
                }

                ForEach(
                    services.profilesByCategory.keys.sorted(by: { $0.hashValue < $1.hashValue }),
                    id: \.rawValue
                ) { key in
                    ProfileList(
                        title: key.rawValue.capitalized,
                        profiles: services.profilesByCategory[key] ?? []
                    )
                }
            }
        }
        .onAppear {
            do {
                if let profiles = services.profiles {
                    services.profilesRecents = try profiles.readRecents()
                    services.profilesByCategory = try profiles.readByCategory()
                }
            } catch {
                print(error)
            }
        }
        .onDisappear {
            services.profilesRecents = []
            services.profilesByCategory = [:]
        }
    }

    @ViewBuilder private func ProfileList(
        title: String,
        profiles: [ProfileModel],

        withCategory: Bool = false
    ) -> some View {
        LazyVStack(alignment: .leading) {
            Section(header: Text(title).font(.title2)) {
                ForEach(profiles, id: \.self) {
                    ProfileCard(profile: $0, withCategory: withCategory)
                }
            }
        }
    }
}
