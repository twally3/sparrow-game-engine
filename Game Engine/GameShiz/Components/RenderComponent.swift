class RenderComponent: Component {
    public var mesh: Mesh
    public var textureType: TextureTypes
    
    public var colour: SIMD4<Float>
    public var isLit: Bool
    public var ambient: SIMD3<Float>
    public var diffuse: SIMD3<Float>
    public var specular: SIMD3<Float>
    public var shininess: Float
    
    
    init(mesh: Mesh,
         textureType: TextureTypes = .None,
         colour: SIMD4<Float> = SIMD4<Float>(0.4, 0.4, 0.4, 1.0),
         isLit: Bool = true,
         ambient: SIMD3<Float> = SIMD3<Float>(repeating: 0.1),
         diffuse: SIMD3<Float> = SIMD3<Float>(repeating: 1),
         specular: SIMD3<Float> = SIMD3<Float>(repeating: 1),
         shininess: Float = 2) {
        
        self.mesh = mesh
        self.textureType = textureType
        self.isLit = isLit
        self.colour = colour
        self.ambient = ambient
        self.diffuse = diffuse
        self.specular = specular
        self.shininess = shininess
    }
}
