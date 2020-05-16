class SkyboxComponent: Component {
    public var mesh: Mesh = Entities.meshes[.SkyBox_Custom]
    public var textureType: TextureTypes
    
    init(textureType: TextureTypes = .SkyBox) {
        self.textureType = textureType
    }
}
