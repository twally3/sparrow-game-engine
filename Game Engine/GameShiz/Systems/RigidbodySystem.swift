import MetalKit

class RigidbodySystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let gravity: Float = -9.81
    
    let family = Family.all(components: TransformComponent.self, RigidbodyComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entity in entities {
            let rigidbodyComponent: RigidbodyComponent = entity.getComponent()!
            let transformComponent: TransformComponent = entity.getComponent()!
            
            let force = computeGravityForce(rigidbody: rigidbodyComponent)
            let acceleration = force / rigidbodyComponent.mass
            
            let velocity = rigidbodyComponent.velocity + acceleration * deltaTime
            let position = transformComponent.position + velocity * deltaTime
            
            rigidbodyComponent.velocity = velocity
            transformComponent.position = position
            
            var heightThreshold: Float = 0
            
            if let boundingBoxComponent: BoundingBoxComponent = entity.getComponent() {
                heightThreshold = boundingBoxComponent.size.y / 2
            }
            
            // TEMP
            if transformComponent.position.y <= heightThreshold {
                transformComponent.position.y = heightThreshold
                rigidbodyComponent.velocity.y = 0
            }
        }
    }
    
    func computeGravityForce(rigidbody: RigidbodyComponent) -> SIMD3<Float> {
        return SIMD3<Float>(0, rigidbody.mass * gravity, 0)
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
