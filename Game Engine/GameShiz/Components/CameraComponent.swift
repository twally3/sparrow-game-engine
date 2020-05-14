import simd

class CameraComponent: Component {
    public var viewMatrix = matrix_identity_float4x4
    public var projectionMatrix = matrix_identity_float4x4
}
