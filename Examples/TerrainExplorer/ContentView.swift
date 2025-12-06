import SwiftUI
import NebulaKit

struct ContentView: UIViewRepresentable {
    func makeUIView(context: Context) -> MetalView {
        guard let gpu = GPUContext() else { fatalError("Metal not supported") }
        let metalView = MetalView(context: gpu)

        let renderer = TerrainRenderer(context: gpu,
                                       size: metalView.drawableSize)
        metalView.renderDelegate = renderer
        context.coordinator.renderer = renderer

        return metalView
    }

    func updateUIView(_ uiView: MetalView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var renderer: TerrainRenderer?
    }
}
