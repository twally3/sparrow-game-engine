class RenderComponent: Component {
    public var mesh: Mesh
    public var textureType: TextureTypes
    public var normalMapType: TextureTypes
    public var material: Material?
    
    init(mesh: Mesh,
         textureType: TextureTypes = .None,
         normalMapType: TextureTypes = .None,
         material: Material? = nil) {
        
        self.mesh = mesh
        self.textureType = textureType
        self.normalMapType = normalMapType
        self.material = material
    }
}
