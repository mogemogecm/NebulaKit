import simd

public extension float4x4 {
    static func identity() -> float4x4 {
        matrix_identity_float4x4
    }

    static func translation(_ t: SIMD3<Float>) -> float4x4 {
        var m = identity()
        m.columns.3 = SIMD4(t, 1)
        return m
    }

    static func scale(_ s: SIMD3<Float>) -> float4x4 {
        var m = identity()
        m.columns.0.x = s.x
        m.columns.1.y = s.y
        m.columns.2.z = s.z
        return m
    }

    static func rotationXYZ(_ r: SIMD3<Float>) -> float4x4 {
        let rx = r.x, ry = r.y, rz = r.z
        let cx = cos(rx), sx = sin(rx)
        let cy = cos(ry), sy = sin(ry)
        let cz = cos(rz), sz = sin(rz)

        let rotX = float4x4([
            SIMD4(1, 0, 0, 0),
            SIMD4(0, cx, sx, 0),
            SIMD4(0, -sx, cx, 0),
            SIMD4(0, 0, 0, 1)
        ])

        let rotY = float4x4([
            SIMD4(cy, 0, -sy, 0),
            SIMD4(0, 1, 0, 0),
            SIMD4(sy, 0, cy, 0),
            SIMD4(0, 0, 0, 1)
        ])

        let rotZ = float4x4([
            SIMD4(cz, sz, 0, 0),
            SIMD4(-sz, cz, 0, 0),
            SIMD4(0, 0, 1, 0),
            SIMD4(0, 0, 0, 1)
        ])

        return rotZ * rotY * rotX
    }

    static func perspective(fovY: Float, aspect: Float, nearZ: Float, farZ: Float) -> float4x4 {
        let yScale = 1 / tan(fovY * 0.5)
        let xScale = yScale / aspect
        let zRange = farZ - nearZ
        let z = -(farZ + nearZ) / zRange
        let wz = -2 * farZ * nearZ / zRange

        return float4x4([
            SIMD4(xScale, 0, 0, 0),
            SIMD4(0, yScale, 0, 0),
            SIMD4(0, 0, z, -1),
            SIMD4(0, 0, wz, 0)
        ])
    }

    static func lookAt(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> float4x4 {
        let f = normalize(center - eye)
        let s = normalize(cross(f, up))
        let u = cross(s, f)

        var m = identity()
        m.columns.0 = SIMD4(s, 0)
        m.columns.1 = SIMD4(u, 0)
        m.columns.2 = SIMD4(-f, 0)
        m.columns.3 = SIMD4(0, 0, 0, 1)

        let t = translation(-eye)
        return m * t
    }
}
