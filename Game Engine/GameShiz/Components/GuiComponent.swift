class GuiComponent: Component {
    var view: View
    var textureType: TextureTypes
    
    init(view: View, textureType: TextureTypes) {
        self.view = view
        self.textureType = textureType
    }
}
