import simd

class TransformComponent: Component {
    private var _position: SIMD3<Float>
    private var _scale: SIMD3<Float>
    private var _rotation: SIMD3<Float>
    
    public var modelMatrix: matrix_float4x4 = matrix_identity_float4x4
    
    public var position: SIMD3<Float> {
        get { _position }
        set {
            _position = newValue
            updateModelMatrix()
        }
    }
    
    public var rotation: SIMD3<Float> {
        get { _rotation }
        set {
            _rotation = newValue
            updateModelMatrix()
        }
    }
    
    public var scale: SIMD3<Float> {
        get { _scale }
        set {
            _scale = newValue
            updateModelMatrix()
        }
    }
    
    init(position: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
         rotation: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
         scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)) {
        self._position = position
        self._rotation = rotation
        self._scale = scale
        updateModelMatrix()
    }
    
    func updateModelMatrix() {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(direction: position)
        modelMatrix.rotate(angle: rotation.x, axis: X_AXIS)
        modelMatrix.rotate(angle: rotation.y, axis: Y_AXIS)
        modelMatrix.rotate(angle: rotation.z, axis: Z_AXIS)
        modelMatrix.scale(axis: scale)
        self.modelMatrix = modelMatrix
    }
}
