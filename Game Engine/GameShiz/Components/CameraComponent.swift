import simd

class CameraComponent: Component {
    public var viewMatrix = matrix_identity_float4x4
    public var projectionMatrix = matrix_identity_float4x4
    
    public var degreesFov: Float = 45
    public var near: Float = 0.1
    public var far: Float = 1000
}
