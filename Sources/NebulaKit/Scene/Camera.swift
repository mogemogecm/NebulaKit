import simd

public final class Camera {
    public var position: SIMD3<Float> = SIMD3(0, 0, 5)
    public var target: SIMD3<Float> = .zero
    public var up: SIMD3<Float> = SIMD3(0, 1, 0)

    public var fovY: Float = 60 * .pi / 180
    public var aspect: Float = 1
    public var nearZ: Float = 0.1
    public var farZ: Float = 1000

    public func viewMatrix() -> float4x4 {
        .lookAt(eye: position, center: target, up: up)
    }

    public func projectionMatrix() -> float4x4 {
        .perspective(fovY: fovY, aspect: aspect, nearZ: nearZ, farZ: farZ)
    }
}

public final class OrbitCameraController {
    public private(set) var radius: Float = 30
    public private(set) var azimuth: Float = 0
    public private(set) var elevation: Float = 0.5
    public var target: SIMD3<Float> = .zero

    public init() {}

    public func updateCamera(_ camera: Camera) {
        let x = target.x + radius * cos(elevation) * sin(azimuth)
        let y = target.y + radius * sin(elevation)
        let z = target.z + radius * cos(elevation) * cos(azimuth)
        camera.position = SIMD3(x, y, z)
        camera.target = target
    }

    public func rotate(deltaAzimuth: Float, deltaElevation: Float) {
        azimuth += deltaAzimuth
        elevation = max(-.pi / 2 + 0.01, min(.pi / 2 - 0.01, elevation + deltaElevation))
    }

    public func zoom(by factor: Float) {
        radius = max(5, min(200, radius * factor))
    }
}
