import simd

public struct Uniforms {
    public var modelMatrix: float4x4
    public var viewMatrix: float4x4
    public var projectionMatrix: float4x4
}

public struct Vertex {
    public var position: SIMD3<Float>
    public var normal: SIMD3<Float>
    public var texcoord: SIMD2<Float>
}
