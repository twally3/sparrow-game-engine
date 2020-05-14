import MetalKit

class Scene {
    private var _sceneConstants = SceneConstants()
    
    internal var engine: ECS
    internal var _name: String
    
    
    init(name: String, engine: ECS) {
        self.engine = engine
        self._name = name

        buildScene()
    }
    
    func buildScene() {}
    
    func update(deltaTime: Float) {
        engine.update(deltaTime: deltaTime)
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Rendering Scene \(_name)")
        
        engine.render(renderCommandEncoder: renderCommandEncoder)
        
        renderCommandEncoder.popDebugGroup()
    }
}
