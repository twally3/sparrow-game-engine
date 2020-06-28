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
            let transformComponent = entitiy.getComponent(componentClass: TransformComponent.self)!
            let cameraComponent = entitiy.getComponent(componentClass: CameraComponent.self)!
            
            let qPitch = simd_quatf(angle: transformComponent.rotation.x, axis: SIMD3<Float>(x: 1, y: 0, z: 0))
            let qYaw = simd_quatf(angle: transformComponent.rotation.y, axis: SIMD3<Float>(x: 0, y: 1, z: 0))
            let qRoll = simd_quatf(angle: transformComponent.rotation.z, axis: SIMD3<Float>(x: 0, y: 0, z: 1))

            let orientation = qPitch * qYaw * qRoll
            let rotate = matrix_float4x4(orientation.normalized)

            var translate = matrix_identity_float4x4
            translate.translate(direction: -transformComponent.position)
            
            cameraComponent.viewMatrix = rotate * translate
            cameraComponent.projectionMatrix = matrix_float4x4.perspective(degreesFov: cameraComponent.degreesFov,
                                                                           aspectRatio: Renderer.aspectRatio,
                                                                           near: cameraComponent.near,
                                                                           far: cameraComponent.far)
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        if entities.count != 1 { return }
        let entitiy = entities[0]
        
        let transformComponent = entitiy.getComponent(componentClass: TransformComponent.self)!
        let cameraComponent = entitiy.getComponent(componentClass: CameraComponent.self)!
        
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
}
