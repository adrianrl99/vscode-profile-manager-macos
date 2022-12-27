import SwiftUI

struct ExtensionCard: View {
    @EnvironmentObject var services: Services
    @Binding var ext: ExtensionModel
    @Binding var selected: [Int64]
    @State var installing: Bool = false
    let selectable: Bool
    var isSelected: Bool {
        ext.id != nil && selected.contains(ext.id!)
    }

    init(ext: Binding<ExtensionModel>) {
        selectable = false
        _ext = ext
        _selected = Binding(get: { [] }, set: { _ in })
    }

    init(ext: Binding<ExtensionModel>, selected: Binding<[Int64]>) {
        selectable = true
        _ext = ext
        _selected = selected
    }

    var body: some View {
        Card {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        if let data = ext.image, let nsImage = NSImage(data: data) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(ext.displayName)
                                    .font(.title2)
                                    .bold()
                                    .lineLimit(1)
                                    .help(ext.displayName)

                                Spacer()

                                HStack {
                                    if let installs = ext.installs {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.down.to.line")
                                                .foregroundColor(.gray)
                                            Text(installs)
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    if let averagerating = ext.averagerating {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                            Text(averagerating)
                                        }
                                    }
                                }
                                .fixedSize()
                            }

                            HStack {
                                Text(ext.lastUpdated.date
                                    .formatted(date: .abbreviated, time: .omitted))
                                    .foregroundColor(.gray)

                                Spacer()

                                if let version = ext.version {
                                    Text("v\(version)")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    if let text = ext.shortDescription {
                        Text(text)
                    }

                    HStack(spacing: 4) {
                        if ext.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.orange)
                        }
                        Text(ext.publisherName)
                            .lineLimit(1)

                        Spacer()
                        if ext.installed && selectable, let id = ext.id {
                            Button {
                                if isSelected {
                                    selected.removeAll(where: { $0 == id })
                                } else {
                                    selected.append(id)
                                }
                            } label: {
                                Image(systemName: isSelected
                                    ? "circle.fill"
                                    : "circle")
                                    .foregroundColor(isSelected ? .blue : .gray)
                            }
                            .buttonStyle(.plain)
                        } else if !ext.installed {
                            Button {
                                if !installing {
                                    Task {
                                        installing = true
                                        do {
                                            if let extensions = services.extensions {
                                                ext = try await extensions.install(ext)
                                            }
                                        } catch {
                                            print(error)
                                        }
                                        installing = false
                                    }
                                }
                            } label: {
                                if installing {
                                    ProgressView()
                                        .progressViewStyle(.linear)
                                        .frame(width: 15)
                                } else {
                                    Text("Install")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
