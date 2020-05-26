class BoundingBoxComponent: Component {
    public var position = SIMD3<Float>(0, 0, 0)
    public var size = SIMD3<Float>(0, 0, 0)
    
    init(position: SIMD3<Float>, size: SIMD3<Float>) {
        self.position = position
        self.size = size
    }
}
