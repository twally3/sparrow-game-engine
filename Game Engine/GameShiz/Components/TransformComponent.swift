import simd

class TransformComponent: Component {
    public var position: SIMD3<Float>
    public var scale: SIMD3<Float>
    public var rotation: SIMD3<Float>
    
    var modelMatrix: matrix_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(direction: position)
        modelMatrix.rotate(angle: rotation.x, axis: X_AXIS)
        modelMatrix.rotate(angle: rotation.y, axis: Y_AXIS)
        modelMatrix.rotate(angle: rotation.z, axis: Z_AXIS)
        modelMatrix.scale(axis: scale)
        return modelMatrix
    }
    
    init(position: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
         rotation: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
         scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
}
