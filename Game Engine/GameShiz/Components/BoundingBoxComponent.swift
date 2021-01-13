import simd

class BoundingBoxComponent: Component {
    public var position = SIMD3<Float>(0, 0, 0)
    public var size = SIMD3<Float>(0, 0, 0)
    
    init(position: SIMD3<Float>, size: SIMD3<Float>) {
        self.position = position
        self.size = size
    }
    
    public static func fromBounds(min: vector_float3, max: vector_float3) -> BoundingBoxComponent {
        return BoundingBoxComponent(position: (max + min) / 2,
                             size: max - min)
    }
}
