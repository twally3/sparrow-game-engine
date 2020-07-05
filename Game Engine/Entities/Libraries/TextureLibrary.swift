import MetalKit

enum TextureTypes{
    case None
    case PartyPirateParot
    case Cruiser
    case SkyBox
    
    case MetalPlate_Diff
    case MetalPlate_Normal
    
    case Weed
}

class TextureLibrary: Library<TextureTypes, MTLTexture> {
    private var _library: [TextureTypes : Texture] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Texture("PartyPirateParot"), forKey: .PartyPirateParot)
        _library.updateValue(Texture("cruiser", ext: "bmp", origin: .bottomLeft), forKey: .Cruiser)
        
        _library.updateValue(Texture(["left", "right", "up", "down", "back", "front"]), forKey: .SkyBox)
        
        _library.updateValue(Texture("metal_plate_diff"), forKey: .MetalPlate_Diff)
        _library.updateValue(Texture("metal_plate_nor"), forKey: .MetalPlate_Normal)
        
        _library.updateValue(Texture("weed"), forKey: .Weed)
    }
    
    override subscript(_ type: TextureTypes) -> MTLTexture? {
        return _library[type]?.texture
    }
}

class Texture {
    var texture: MTLTexture!
    
    init(_ textureName: String, ext: String = "png", origin: MTKTextureLoader.Origin = .topLeft){
        let textureLoader = TextureLoader(textureName: textureName, textureExtension: ext, origin: origin)
        let texture: MTLTexture = textureLoader.loadTextureFromBundle()
        setTexture(texture)
    }
    
    init(_ textureNames: [String], ext: String = "png", origin: MTKTextureLoader.Origin = .topLeft) {
        var texture: MTLTexture!
        
        texture = loadCubeMap(textureNames: textureNames, ext: ext, origin: origin)
        
        setTexture(texture)
    }
    
    func loadCubeMap(textureNames: [String], ext: String, origin: MTKTextureLoader.Origin) -> MTLTexture {
        var texture: MTLTexture!
        let scale: Int = 1
        #if os(iOS)
            let firstImage = UIImage(named: textureNames.first!)
        #elseif os(macOS)
            let firstImage = NSImage(named: textureNames.first!)
        #endif
        let cubeSize = Int(firstImage!.size.width) * scale

        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .bgra8Unorm_srgb
        textureDescriptor.height = cubeSize
        textureDescriptor.width = cubeSize
        textureDescriptor.textureType = .typeCube
        
        texture = Engine.device.makeTexture(descriptor: textureDescriptor)

        for (i, imageName) in textureNames.enumerated() {
            let textureLoader = TextureLoader(textureName: imageName, textureExtension: ext, origin: origin)
            let tex: MTLTexture = textureLoader.loadTextureFromBundle()
            
            let rowBytes = cubeSize * 4
            let length = rowBytes * cubeSize
            var bgraBytes = [UInt8](repeating: 0, count: length)

            bgraBytes.withUnsafeMutableBytes { ptr in
                tex.getBytes(ptr.baseAddress!,
                             bytesPerRow: rowBytes,
                             from: MTLRegionMake2D(0, 0, cubeSize, cubeSize),
                             mipmapLevel: 0)
            }
            
            texture.replace(region: MTLRegionMake2D(0, 0, cubeSize, cubeSize),
                             mipmapLevel: 0,
                             slice: i,
                             withBytes: bgraBytes,
                             bytesPerRow: rowBytes,
                             bytesPerImage: bgraBytes.count)
        }
        
        return texture
    }
    
    func setTexture(_ texture: MTLTexture){
        self.texture = texture
    }
}

class TextureLoader {
    private var _textureName: String!
    private var _textureExtension: String!
    private var _origin: MTKTextureLoader.Origin!
    
    init(textureName: String, textureExtension: String = "png", origin: MTKTextureLoader.Origin = .topLeft){
        self._textureName = textureName
        self._textureExtension = textureExtension
        self._origin = origin
    }
    
    public func loadTextureFromBundle()->MTLTexture{
        var result: MTLTexture!
        if let url = Bundle.main.url(forResource: _textureName, withExtension: self._textureExtension) {
            let textureLoader = MTKTextureLoader(device: Engine.device)
            
            let options: [MTKTextureLoader.Option : Any] = [
                MTKTextureLoader.Option.origin : _origin as Any,
                MTKTextureLoader.Option.generateMipmaps : true
            ]
            
            do{
                result = try textureLoader.newTexture(URL: url, options: options)
                result.label = _textureName
            }catch let error as NSError {
                print("ERROR::CREATING::TEXTURE::__\(_textureName!)__::\(error)")
            }
        }else {
            print("ERROR::CREATING::TEXTURE::__\(_textureName!) does not exist")
        }
        
        return result
    }
}
