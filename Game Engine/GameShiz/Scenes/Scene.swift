import MetalKit

class Scene {
    private var _cameraManager = CameraManager()
    private var _sceneConstants = SceneConstants()
    
    internal var engine: ECS
    internal var _name: String
    
    
    init(name: String, engine: ECS) {
        self.engine = engine
        self._name = name

        buildScene()
    }
    
    func buildScene() {}
    
    func addCamera(_ camera: Camera, _ isCurrentCamera: Bool = true) {
        _cameraManager.registerCamera(camera: camera)
        
        if (isCurrentCamera) {
            _cameraManager.setCamera(camera.cameraType)
        }
    }
    
    func updateCameras() {
        _cameraManager.update()
    }
    
    func update(deltaTime: Float) {
        _sceneConstants.viewMatrix = _cameraManager.currentCamera.viewMatrix
        _sceneConstants.projectionMatrix = _cameraManager.currentCamera.projectionMatrix
        _sceneConstants.cameraPosition = _cameraManager.currentCamera.getPosition()
        
        engine.update(deltaTime: deltaTime)
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Rendering Scene \(_name)")
        renderCommandEncoder.setVertexBytes(&_sceneConstants, length: SceneConstants.stride, index: 1)
        engine.render(renderCommandEncoder: renderCommandEncoder)
        renderCommandEncoder.popDebugGroup()
    }
}
