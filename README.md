NebulaKit
NebulaKit is a Metal-based iOS 3D scene and terrain rendering library designed for rapidly building interactive 3D browsers, terrain visualization, and simple game prototypes. It provides a complete set of foundational capabilities from GPU abstraction and scene management to terrain and model loading, allowing you to focus on building content rather than low-level rendering frameworks.

Features
Metal Rendering Abstraction: Unified GPUContext and reusable rendering view MetalView simplify device and command queue management.

Scene/Node System: Scene + SceneNode manage hierarchical transformations and meshes, making it easy to organize complex scene structures.

Camera and Interaction: Built-in Camera and OrbitCameraController support orbit camera controls with zoom and rotation interactions.

Terrain Heightfield Support: HeightfieldTerrain converts height data into renderable meshes for maps, terrain, or scientific data visualization.

3D Model Loading: Uses Model I/O to load common 3D model formats, outputting unified MeshResource for scene use.

NebulaKit doesn't depend on SceneKit or third-party rendering engines, implementing directly with Metal API. It can serve as a foundation for learning Metal or building custom engines.

Requirements
iOS 15 and above

Xcode 15 and above

Metal-capable iOS devices

Quick Start
Integration with Swift Package Manager
In Xcode:

Open Project Settings → Package Dependencies

Click + to add a new dependency and enter this repository's URL

Select NebulaKit as a dependency to add to your App Target

Creating a Minimal Scene
swift
import SwiftUI
import NebulaKit

struct ContentView: UIViewRepresentable {
    func makeUIView(context: Context) -> MetalView {
        guard let gpu = GPUContext() else {
            fatalError("Metal not supported")
        }
        let metalView = MetalView(context: gpu)
        let renderer = SimpleSceneRenderer(context: gpu, size: metalView.drawableSize)
        metalView.renderDelegate = renderer
        context.coordinator.renderer = renderer
        return metalView
    }
    
    func updateUIView(_ uiView: MetalView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator {
        var renderer: SimpleSceneRenderer?
    }
}
You simply need to implement a custom SimpleSceneRenderer, create a Scene within it, configure the camera, and complete rendering in each frame callback.

Example Project: TerrainExplorer
The repository includes an example app at Examples/TerrainExplorer demonstrating:

Generating terrain meshes from heightmaps and rendering them

Browsing scenes with an orbit camera (drag to rotate, pinch to zoom)

Clicking terrain to highlight specific locations

The example code structure is clear and can serve as a reference for customization or extension.

Design Philosophy
NebulaKit focuses on several key points:

Clear Layering: Core (Metal abstraction), Scene (scene and camera), Terrain (terrain), and ModelIOBridge (model loading) are clearly separated for easy replacement and extension.

Readability First: API naming favors self-explanation over abbreviation, facilitating team collaboration and future maintenance.

Extensibility: You can add advanced effects like lighting, shadows, and post-processing on the existing foundation without refactoring the entire framework.

License
You can choose an appropriate open-source license for NebulaKit (such as MIT or Apache-2.0) to meet your project needs.
