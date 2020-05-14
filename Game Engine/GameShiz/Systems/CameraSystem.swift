import MetalKit

class CameraSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, CameraComponent.self, MouseInputComponent.self, KeyboardInputComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entitiy in entities {
            let transformComponent = entitiy.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            let cameraComponent = entitiy.getComponent(componentClass: CameraComponent.self) as! CameraComponent
            let mouseInputComponent = entitiy.getComponent(componentClass: MouseInputComponent.self) as! MouseInputComponent
            let keyboardInputComponent = entitiy.getComponent(componentClass: KeyboardInputComponent.self) as! KeyboardInputComponent
                        
            self.keyPressed(deltaTime: deltaTime, transformComp: transformComponent, cameraComp: cameraComponent, keyboardComp: keyboardInputComponent)
            self.mouseMove(deltaTime: deltaTime, transformComp: transformComponent, mouseInputComponent: mouseInputComponent)
            
            cameraComponent.viewMatrix = getNewViewMatrix(transformComponent: transformComponent)
            cameraComponent.projectionMatrix = matrix_float4x4.perspective(degreesFov: cameraComponent.degreesFov,
                                                                           aspectRatio: Renderer.aspectRatio,
                                                                           near: cameraComponent.near,
                                                                           far: cameraComponent.far)
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
    
    private func keyPressed(deltaTime: Float, transformComp: TransformComponent, cameraComp: CameraComponent, keyboardComp: KeyboardInputComponent) {
        var dx: Float = 0
        var dz: Float = 0
        
        if keyboardComp.w { dz = 2 }
        else if keyboardComp.s { dz = -2 }
        
        if keyboardComp.d { dx = 2 }
        else if keyboardComp.a { dx = -2 }

        let mat = cameraComp.viewMatrix

        let forward = SIMD3<Float>(x: mat[0][2], y: mat[1][2], z: mat[2][2])
        let strafe = SIMD3<Float>(x: mat[0][0], y: mat[1][0], z: mat[2][0])


        let speed: Float = 2
        let direction = -dz * forward + dx * strafe
        
        transformComp.position += direction * speed * deltaTime
    }
    
    private func mouseMove(deltaTime: Float, transformComp: TransformComponent, mouseInputComponent: MouseInputComponent) {
        if !mouseInputComponent.right { return }
        let mouseDelta = SIMD2<Float>(x: mouseInputComponent.dx, y: mouseInputComponent.dy)

        let mouseXSensitivity: Float = 1
        let mouseYSensitivity: Float = 1
        
        transformComp.rotation.y += mouseXSensitivity * mouseDelta.x * deltaTime
        transformComp.rotation.x += mouseYSensitivity * mouseDelta.y * deltaTime
    }
    
    private func getNewViewMatrix(transformComponent: TransformComponent) -> matrix_float4x4 {
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
