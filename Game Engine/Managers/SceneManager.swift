import MetalKit

enum SceneTypes {
    case Sandbox
}

class SceneManager {
    private static var _currentScene: Scene!
    private static var engine: ECS!
    
    public static func initialize(_ sceneType: SceneTypes) {
        engine = ECS()
        setScene(sceneType: sceneType)
        
        do {
            try engine.addSystem(system: MouseInputSystem(priority: 0))
            try engine.addSystem(system: KeyboardInputSystem(priority: 0))
            try engine.addSystem(system: CameraSystem(priority: 0))
            try engine.addSystem(system: LightSystem(priority: 0))
            try engine.addSystem(system: SkyboxSystem(priority: 0))
            try engine.addSystem(system: RenderSystem(priority: 0))
            try engine.addSystem(system: InstancedRenderSystem(priority: 0))
            try engine.addSystem(system: ParticleSystemSystem(priority: 0))
            try engine.addSystem(system: ParticleSystem(priority: 0))
            try engine.addSystem(system: FPSCameraSystem(priority: 0))
            try engine.addSystem(system: CollisionSystem(priority: 0))
            
            try engine.addSystem(system: RotationSystem(priority: 1))
            try engine.addSystem(system: MovableSystem(priority: 1))
        } catch let error {
            fatalError("\(error)")
        }
    }
    
    public static func setScene(sceneType: SceneTypes) {
        switch sceneType {
        case .Sandbox:
            _currentScene = SandboxScene(name: "Sandbox", engine: engine)
        }
    }
    
    public static func tickScene(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        GameTime.updateTime(deltaTime)
        
        _currentScene.update(deltaTime: deltaTime)
        _currentScene.render(renderCommandEncoder: renderCommandEncoder)
    }
}
