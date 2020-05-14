class RenderComponent: Component {
    public var isLit: Bool
    public var colour: SIMD4<Float>
    public var mesh: Mesh
    
    init(isLit: Bool, colour: SIMD4<Float>, mesh: Mesh) {
        self.isLit = isLit
        self.colour = colour
        self.mesh = mesh
    }
}
