import SwiftUI

struct Layout<Content: View, Actions: View>: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.isPresented) var isPresented: Bool

    let title: String
    let actions: Actions
    let content: Content

    init(_ title: String,
         @ViewBuilder content: () -> Content,
         @ViewBuilder actions: () -> Actions)
    {
        self.title = title
        self.actions = actions()
        self.content = content()
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    if isPresented {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.backward")
                        }
                    }

                    Text(title)
                        .font(.title3)
                        .bold()

                    Spacer(minLength: 0)

                    actions
                }
                .padding(10)
                .background(.thickMaterial)

                Divider()
            }

            content

            Spacer(minLength: 0)
        }
        .padding(.bottom, 10)
        .navigationBarBackButtonHidden(true)
        .frame(width: 320, height: 600)
    }
}

#if DEBUG
    struct Layout_Previews: PreviewProvider {
        static var previews: some View {
            Layout("Preview") {
                Text("Content")
            } actions: {
                Button("Action", action: {})
            }
        }
    }
#endif
