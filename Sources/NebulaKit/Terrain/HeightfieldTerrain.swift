import Metal
import simd

public struct TerrainVertex {
    public var position: SIMD3<Float>
    public var normal: SIMD3<Float>
    public var texcoord: SIMD2<Float>
}

public final class HeightfieldTerrain {
    public let vertexBuffer: MTLBuffer
    public let indexBuffer: MTLBuffer
    public let indexCount: Int

    public init?(context: GPUContext, heightMap: [Float], width: Int, height: Int, scale: SIMD3<Float>) {
        let device = context.device

        var vertices: [TerrainVertex] = []
        vertices.reserveCapacity(width * height)

        // 简单高度图网格
        for y in 0..<height {
            for x in 0..<width {
                let i = y * width + x
                let h = heightMap[i]
                let pos = SIMD3<Float>(
                    Float(x) * scale.x,
                    h * scale.y,
                    Float(y) * scale.z
                )
                let tex = SIMD2<Float>(Float(x) / Float(width - 1),
                                       Float(y) / Float(height - 1))
                let v = TerrainVertex(position: pos,
                                      normal: SIMD3<Float>(0, 1, 0),
                                      texcoord: tex)
                vertices.append(v)
            }
        }

        var indices: [UInt32] = []
        for y in 0..<height-1 {
            for x in 0..<width-1 {
                let i0 = UInt32(y * width + x)
                let i1 = UInt32(y * width + x + 1)
                let i2 = UInt32((y + 1) * width + x)
                let i3 = UInt32((y + 1) * width + x + 1)
                indices.append(contentsOf: [i0, i2, i1, i1, i2, i3])
            }
        }

        guard
            let vb = device.makeBuffer(bytes: vertices,
                                       length: MemoryLayout<TerrainVertex>.stride * vertices.count,
                                       options: []),
            let ib = device.makeBuffer(bytes: indices,
                                       length: MemoryLayout<UInt32>.stride * indices.count,
                                       options: [])
        else { return nil }

        vertexBuffer = vb
        indexBuffer = ib
        indexCount = indices.count
    }
}
