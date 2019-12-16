import simd

class Sun: LightObject {
    init() {
        super.init(meshType: .Sphere, name: "Sun")
        self.setColour(SIMD4<Float>(0.5, 0.5, 0.0, 1.0))
        self.setScale(SIMD3<Float>(repeating: 0.3))
    }
}