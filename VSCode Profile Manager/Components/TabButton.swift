import SwiftUI

struct TabButton<T: Equatable>: View {
    let image: String
    let title: String
    let tab: T

    @Binding var selected: T

    var body: some View {
        Button { withAnimation { selected = tab } } label: {
            HStack(spacing: 10) {
                Image(systemName: image)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selected == tab ? .white : .gray)

                Text(title)
                    .fontWeight(.semibold)

                    .foregroundColor(selected == tab ? .white : .gray)

                Spacer()
            }
            .padding(8)
            .frame(width: 150)
            .contentShape(Rectangle())
            .background(.primary.opacity(selected == tab ? 0.15 : 0))
            .cornerRadius(5)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
    struct TabButton_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                TabButton(
                    image: "viewfinder",
                    title: "Profile",
                    tab: 1,
                    selected: .constant(1)
                )
                TabButton(
                    image: "viewfinder",
                    title: "Extensions",
                    tab: 2,
                    selected: .constant(1)
                )
            }
            .background(BlurWindow())
            .ignoresSafeArea(.all, edges: .all)
            .padding()
        }
    }
#endif
