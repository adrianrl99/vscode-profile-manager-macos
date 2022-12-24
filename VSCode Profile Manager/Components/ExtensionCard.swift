import SwiftUI

struct ExtensionCard: View {
    @EnvironmentObject var services: Services
    @Binding var ext: ExtensionModel.Card

    var body: some View {
        Card {
            HStack(spacing: 12) {
                HStack {
                    if let image = ext.image {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 80, height: 80)

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
                        Text(ext.releaseDate.date
                            .formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(.gray)

                        Spacer()

                        if let version = ext.version {
                            Text("v\(version)")
                                .foregroundColor(.gray)
                        }
                    }

                    Text(ext.shortDescription ?? " ")
                        .lineLimit(1)
                        .help(ext.shortDescription ?? " ")

                    HStack(spacing: 4) {
                        if ext.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.orange)
                        }
                        Text(ext.publisherName)
                            .lineLimit(1)

                        Spacer()

                        HStack {
                            Button("Install", action: {})
                        }
                    }
                }
            }
        }
    }
}
