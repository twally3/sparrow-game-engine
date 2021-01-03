import MetalKit

class Renderer: NSObject {
    var time: Date = Date()
    public static var screenSize = SIMD2<Float>(repeating: 0)
    public static var aspectRatio: Float {
        return screenSize.x / screenSize.y
    }
    public static var engine = ViewConstraintEngine(width: screenSize.x, height: screenSize.y)
    
    init(_ mtkView: MTKView) {
        super.init()
        updateScreenSize(view: mtkView)
    }
}

extension Renderer: MTKViewDelegate {
    public func updateScreenSize(view: MTKView) {
        Renderer.screenSize = SIMD2<Float>(Float(view.bounds.width), Float(view.bounds.height))
        Renderer.engine.window.updateFrame(width: Float(view.bounds.width), height: Float(view.bounds.height))
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    func draw(in view: MTKView) {
        let newDate = Date()
        let elapsed = newDate.timeIntervalSince(time)
        time = newDate
        
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = Engine.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "My Command Buffer"
        
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderCommandEncoder?.label = "My Render Command Encoder"
        
        renderCommandEncoder?.setFrontFacing(.counterClockwise)
        renderCommandEncoder?.setCullMode(.back)
        
        renderCommandEncoder?.pushDebugGroup("Starting Render")
        SceneManager.tickScene(renderCommandEncoder: renderCommandEncoder!, deltaTime: Float(elapsed))
        renderCommandEncoder?.popDebugGroup()
        
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
