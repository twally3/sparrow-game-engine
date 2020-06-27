class RotatableComponent: Component {
    public var axis: SIMD3<Float>
    public var isMouseControlled: Bool
    
    init(axis: SIMD3<Float> = SIMD3<Float>(0, 0, 0), isMouseControlled: Bool = false) {
        self.axis = axis
        self.isMouseControlled = isMouseControlled
    }
}
