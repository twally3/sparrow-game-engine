import MetalKit

class FPSCameraSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, CameraComponent.self, MouseInputComponent.self, KeyboardInputComponent.self, FPSCameraComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entitiy in entities {
            let transformComponent = entitiy.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            let cameraComponent = entitiy.getComponent(componentClass: CameraComponent.self) as! CameraComponent
            let mouseInputComponent = entitiy.getComponent(componentClass: MouseInputComponent.self) as! MouseInputComponent
            let keyboardInputComponent = entitiy.getComponent(componentClass: KeyboardInputComponent.self) as! KeyboardInputComponent
            let fpsCameraComponent = entitiy.getComponent(componentClass: FPSCameraComponent.self) as! FPSCameraComponent
                        
            // Keyboard
            var dx: Float = 0
            var dz: Float = 0
            
            if keyboardInputComponent.w { dz = 2 }
            else if keyboardInputComponent.s { dz = -2 }
            
            if keyboardInputComponent.d { dx = 2 }
            else if keyboardInputComponent.a { dx = -2 }

            let mat = cameraComponent.viewMatrix

            let forward = SIMD3<Float>(x: mat[0][2], y: mat[1][2], z: mat[2][2])
            let strafe = SIMD3<Float>(x: mat[0][0], y: mat[1][0], z: mat[2][0])

            let direction = -dz * forward + dx * strafe
            transformComponent.position += direction * fpsCameraComponent.speed * deltaTime
            
            // Mouse
            if !mouseInputComponent.right { return }
            let mouseDelta = SIMD2<Float>(x: mouseInputComponent.dx, y: mouseInputComponent.dy)

            transformComponent.rotation.y += fpsCameraComponent.mouseXSensitivity * mouseDelta.x * deltaTime
            transformComponent.rotation.x += fpsCameraComponent.mouseYSensitivity * mouseDelta.y * deltaTime
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {}
    
    func onEntityAdded(entity: Entity) {
        if family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
        }
    }
    
    func onEntityRemoved(entity: Entity) {
        if !family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
        }
    }
    
    func onAddedToEngine(engine: ECS) {
        self.entities = engine.getEntities(for: family)
        self.engine = engine
    }
}
