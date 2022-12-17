import SwiftUI

struct BlurWindow: NSViewRepresentable {
    func makeNSView(context _: Self.Context) -> NSView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}
