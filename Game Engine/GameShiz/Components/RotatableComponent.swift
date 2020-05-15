class RotatableComponent: Component {
    public var axis: SIMD3<Float>
    
    init(axis: SIMD3<Float> = SIMD3<Float>(0, 0, 0)) {
        self.axis = axis
    }
}
