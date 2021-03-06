import MetalKit

enum RenderPipelineStateTypes {
    case Basic
    case Instanced
    case SkyBox
    case Gui
}

class RenderPipelineStateLibrary: Library<RenderPipelineStateTypes, MTLRenderPipelineState> {
    private var _library: [RenderPipelineStateTypes: RenderPipelineState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Basic_RenderPipelineState(), forKey: .Basic)
        _library.updateValue(Instanced_RenderPipelineState() , forKey: .Instanced)
        _library.updateValue(SkyBox_RenderPipelineState(), forKey: .SkyBox)
        _library.updateValue(Gui_RenderPipelineState(), forKey: .Gui)
    }
    
    override subscript(_ type: RenderPipelineStateTypes) -> MTLRenderPipelineState {
        return _library[type]!.renderPipelineState
    }
}

class RenderPipelineState {
    var renderPipelineState: MTLRenderPipelineState!
    
    init(renderPipelineDescriptor: MTLRenderPipelineDescriptor) {
        do {
            renderPipelineState = try Engine.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__::\(error)")
        }
    }
}

class Basic_RenderPipelineState: RenderPipelineState {
    init() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "Basic Render Pipeline Descriptor"

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.Basic]
        
        renderPipelineDescriptor.vertexFunction = Graphics.shaders[.Basic_Vertex]
        renderPipelineDescriptor.fragmentFunction = Graphics.shaders[.Basic_Fragment]
        
        super.init(renderPipelineDescriptor: renderPipelineDescriptor)
    }
}

class Instanced_RenderPipelineState: RenderPipelineState {
    init() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "Instanced Render Pipeline Descriptor"

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.Basic]
        
        renderPipelineDescriptor.vertexFunction = Graphics.shaders[.Instanced_Vertex]
        renderPipelineDescriptor.fragmentFunction = Graphics.shaders[.Basic_Fragment]
        
        super.init(renderPipelineDescriptor: renderPipelineDescriptor)
    }
}

class SkyBox_RenderPipelineState: RenderPipelineState {
    init() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "SkyBox Render Pipeline Descriptor"

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.Basic]
        
        renderPipelineDescriptor.vertexFunction = Graphics.shaders[.SkyBox_Vertex]
        renderPipelineDescriptor.fragmentFunction = Graphics.shaders[.SkyBox_Fragment]
        
        super.init(renderPipelineDescriptor: renderPipelineDescriptor)
    }
}

class Gui_RenderPipelineState: RenderPipelineState {
    init() {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.label = "Gui Render Pipeline Descriptor"

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthPixelFormat
//        renderPipelineDescriptor.vertexDescriptor = Graphics.vertexDescriptors[.Basic]
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
//        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .one
//        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
        
        renderPipelineDescriptor.vertexFunction = Graphics.shaders[.Gui_Vertex]
        renderPipelineDescriptor.fragmentFunction = Graphics.shaders[.Gui_Fragment]
        
        super.init(renderPipelineDescriptor: renderPipelineDescriptor)
    }
}
