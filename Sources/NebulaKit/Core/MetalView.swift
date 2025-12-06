import MetalKit

public protocol MetalViewDelegate: AnyObject {
    func draw(in view: MetalView,
              commandBuffer: MTLCommandBuffer,
              drawable: CAMetalDrawable,
              renderPassDescriptor: MTLRenderPassDescriptor)
    func drawableSizeDidChange(to size: CGSize)
}

public final class MetalView: MTKView, MTKViewDelegate {
    public weak var renderDelegate: MetalViewDelegate?

    public init(context: GPUContext, frame: CGRect = .zero) {
        super.init(frame: frame, device: context.device)
        framebufferOnly = false
        colorPixelFormat = .bgra8Unorm
        depthStencilPixelFormat = .depth32Float
        isPaused = false
        enableSetNeedsDisplay = false
        preferredFramesPerSecond = 60
        delegate = self
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderDelegate?.drawableSizeDidChange(to: size)
    }

    public func draw(in view: MTKView) {
        guard
            let drawable = currentDrawable,
            let descriptor = currentRenderPassDescriptor,
            let commandBuffer = device?.makeCommandQueue()?.makeCommandBuffer()
        else { return }

        renderDelegate?.draw(in: self,
                             commandBuffer: commandBuffer,
                             drawable: drawable,
                             renderPassDescriptor: descriptor)
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
