import MetalKit

enum SceneTypes {
    case Sandbox
    case Forest
    case Debug
}

class SceneManager {
    private static var _currentScene: Scene!
    private static var engine: ECS!
    
    public static func initialize(_ sceneType: SceneTypes) {
        engine = ECS()
        
        do {
            try engine.addSystem(system: MouseInputSystem(priority: 0))
            try engine.addSystem(system: KeyboardInputSystem(priority: 0))
            try engine.addSystem(system: CameraSystem(priority: 0))
            try engine.addSystem(system: LightSystem(priority: 0))
            try engine.addSystem(system: SkyboxSystem(priority: 0))
            try engine.addSystem(system: RenderSystem(priority: 0))
            try engine.addSystem(system: InstancedRenderSystem(priority: 0))
            try engine.addSystem(system: FPSCameraSystem(priority: 0))
            try engine.addSystem(system: CollisionSystem(priority: 0))
            
            try engine.addSystem(system: RotationSystem(priority: 1))
            try engine.addSystem(system: MovableSystem(priority: 1))
            
            try engine.addSystem(system: GuiSystem(priority: 1000))
        } catch let error {
            fatalError("\(error)")
        }
        
        setScene(sceneType: sceneType)
    }
    
    public static func setScene(sceneType: SceneTypes) {
        switch sceneType {
        case .Sandbox:
            _currentScene = SandboxScene(name: "Sandbox", engine: engine)
        case .Forest:
            _currentScene = ForestScene(name: "Forest", engine: engine)
        case .Debug:
            _currentScene = DebugScene(name: "Debug", engine: engine)
        }
    }
    
    public static func tickScene(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        GameTime.updateTime(deltaTime)
        
        _currentScene.update(deltaTime: deltaTime)
        _currentScene.render(renderCommandEncoder: renderCommandEncoder)
    }
}
