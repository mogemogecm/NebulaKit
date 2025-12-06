import Metal
import ModelIO
import MetalKit

public struct MeshResource {
    public let vertexBuffer: MTLBuffer
    public let indexBuffer: MTLBuffer
    public let indexCount: Int
}

public final class ModelLoader {
    private let context: GPUContext
    private let allocator: MTKMeshBufferAllocator

    public init(context: GPUContext) {
        self.context = context
        self.allocator = MTKMeshBufferAllocator(device: context.device)
    }

    public func loadMesh(url: URL) throws -> MeshResource {
        let asset = MDLAsset(url: url, vertexDescriptor: nil, bufferAllocator: allocator)
        guard let mdlMesh = asset.object(at: 0) as? MDLMesh else {
            throw NSError(domain: "NebulaKit",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No mesh in asset"])
        }

        let mtkMesh = try MTKMesh(mesh: mdlMesh, device: context.device)
        guard
            let vb = mtkMesh.vertexBuffers.first?.buffer,
            let submesh = mtkMesh.submeshes.first
        else {
            throw NSError(domain: "NebulaKit",
                          code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid mesh"])
        }

        return MeshResource(vertexBuffer: vb,
                            indexBuffer: submesh.indexBuffer.buffer,
                            indexCount: submesh.indexCount)
    }
}
