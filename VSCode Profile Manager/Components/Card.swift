import SwiftUI

struct Card<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding()
            .background(Color.primary.opacity(0.05))
            .background(.thinMaterial)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}

#if DEBUG
    struct Card_Previews: PreviewProvider {
        static var previews: some View {
            Card {
                Text("Preview")
            }
            .padding()
            .background(BlurWindow())
        }
    }
#endif
