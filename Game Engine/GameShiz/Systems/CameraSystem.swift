import MetalKit

class CameraSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, CameraComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entitiy in entities {
            let transformComponent = entitiy.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            let cameraComponent = entitiy.getComponent(componentClass: CameraComponent.self) as! CameraComponent
            
            self.keyPressed(deltaTime: deltaTime, transformComp: transformComponent, cameraComp: cameraComponent)
            self.mouseMove(deltaTime: deltaTime, transformComp: transformComponent)
            
            cameraComponent.viewMatrix = getNewViewMatrix(transformComponent: transformComponent)
            cameraComponent.projectionMatrix = matrix_float4x4.perspective(degreesFov: 45.0, aspectRatio: Renderer.aspectRatio, near: 0.1, far: 1000)
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        if entities.count != 1 { return }
        let entitiy = entities[0]
        
        let transformComponent = entitiy.getComponent(componentClass: TransformComponent.self) as! TransformComponent
        let cameraComponent = entitiy.getComponent(componentClass: CameraComponent.self) as! CameraComponent
        
        var sceneConstants = SceneConstants(viewMatrix: cameraComponent.viewMatrix,
                                            projectionMatrix: cameraComponent.projectionMatrix,
                                            cameraPosition: transformComponent.position)
        
        renderCommandEncoder.setVertexBytes(&sceneConstants, length: SceneConstants.stride, index: 1)
        
    }
    
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
    
    func keyPressed(deltaTime: Float, transformComp: TransformComponent, cameraComp: CameraComponent) {
        var dx: Float = 0
        var dz: Float = 0

        if (Keyboard.isKeyPressed(.w)) {
            dz = 2
        } else if (Keyboard.isKeyPressed(.s)) {
            dz = -2
        } else if (Keyboard.isKeyPressed(.a)) {
            dx = -2
        } else if (Keyboard.isKeyPressed(.d)) {
            dx = 2
        }

        let mat = cameraComp.viewMatrix

        let forward = SIMD3<Float>(x: mat[0][2], y: mat[1][2], z: mat[2][2])
        let strafe = SIMD3<Float>(x: mat[0][0], y: mat[1][0], z: mat[2][0])


        let speed: Float = 2
        let direction = -dz * forward + dx * strafe
        
        transformComp.position += direction * speed * deltaTime
    }
    
    func mouseMove(deltaTime: Float, transformComp: TransformComponent) {
        if !Mouse.isMouseButtonPressed(button: .RIGHT) { return }
        let mousePos = SIMD2<Float>(x: Mouse.getDX(), y: Mouse.getDY())
        let mouseDelta = mousePos

        let mouseXSensitivity: Float = 1
        let mouseYSensitivity: Float = 1
        
        transformComp.rotation.y += mouseXSensitivity * mouseDelta.x * deltaTime
        transformComp.rotation.x += mouseYSensitivity * mouseDelta.y * deltaTime
    }
    
    func getNewViewMatrix(transformComponent: TransformComponent) -> matrix_float4x4 {
        let qPitch = simd_quatf(angle: transformComponent.rotation.x, axis: SIMD3<Float>(x: 1, y: 0, z: 0))
        let qYaw = simd_quatf(angle: transformComponent.rotation.y, axis: SIMD3<Float>(x: 0, y: 1, z: 0))
        let qRoll = simd_quatf(angle: transformComponent.rotation.z, axis: SIMD3<Float>(x: 0, y: 0, z: 1))

        let orientation = qPitch * qYaw * qRoll
        let rotate = matrix_float4x4(orientation.normalized)

        var translate = matrix_identity_float4x4
        translate.translate(direction: -transformComponent.position)
        
        return rotate * translate
    }
}
