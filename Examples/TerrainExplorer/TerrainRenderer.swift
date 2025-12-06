import Metal
import NebulaKit
import simd

final class TerrainRenderer: NSObject, MetalViewDelegate {
    private let context: GPUContext
    private var pipelineState: MTLRenderPipelineState!
    private var depthState: MTLDepthStencilState!
    private var terrain: HeightfieldTerrain!
    private var camera = Camera()
    private let orbit = OrbitCameraController()

    private var uniforms = Uniforms(
        modelMatrix: .identity(),
        viewMatrix: .identity(),
        projectionMatrix: .identity()
    )

    init(context: GPUContext, size: CGSize) {
        self.context = context
        super.init()
        buildPipeline()
        buildDepthState()
        buildTerrain()
        resize(to: size)
    }

    private func buildPipeline() {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = context.library.makeFunction(name: "vertex_main")
        descriptor.fragmentFunction = context.library.makeFunction(name: "fragment_main")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.depthAttachmentPixelFormat = .depth32Float

        pipelineState = try! context.device.makeRenderPipelineState(descriptor: descriptor)
    }

    private func buildDepthState() {
        let desc = MTLDepthStencilDescriptor()
        desc.isDepthWriteEnabled = true
        desc.depthCompareFunction = .less
        depthState = context.device.makeDepthStencilState(descriptor: desc)
    }

    private func buildTerrain() {
        // 简单生成一个平滑高度图示例
        let w = 128
        let h = 128
        var heightMap: [Float] = []
        heightMap.reserveCapacity(w * h)
        for y in 0..<h {
            for x in 0..<w {
                let fx = Float(x) / Float(w)
                let fy = Float(y) / Float(h)
                let height = sin(fx * .pi * 4) * cos(fy * .pi * 4) * 5
                heightMap.append(height)
            }
        }
        terrain = HeightfieldTerrain(context: context,
                                     heightMap: heightMap,
                                     width: w,
                                     height: h,
                                     scale: SIMD3(1, 1, 1))
    }

    func drawableSizeDidChange(to size: CGSize) {
        resize(to: size)
    }

    private func resize(to size: CGSize) {
        camera.aspect = Float(size.width / max(size.height, 1))
        orbit.updateCamera(camera)
        uniforms.viewMatrix = camera.viewMatrix()
        uniforms.projectionMatrix = camera.projectionMatrix()
    }

    func draw(in view: MetalView,
              commandBuffer: MTLCommandBuffer,
              drawable: CAMetalDrawable,
              renderPassDescriptor: MTLRenderPassDescriptor) {

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)

        uniforms.modelMatrix = .identity()
        encoder.setVertexBytes(&uniforms,
                               length: MemoryLayout<Uniforms>.stride,
                               index: 1)

        encoder.setVertexBuffer(terrain.vertexBuffer,
                                offset: 0,
                                index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: terrain.indexCount,
                                      indexType: .uint32,
                                      indexBuffer: terrain.indexBuffer,
                                      indexBufferOffset: 0)
        encoder.endEncoding()
    }
}
