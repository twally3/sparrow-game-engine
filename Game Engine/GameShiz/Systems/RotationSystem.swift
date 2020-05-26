import MetalKit

class RotationSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, RotatableComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entity in entities {
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            let rotatableComponent = entity.getComponent(componentClass: RotatableComponent.self) as! RotatableComponent
            
//            transformComponent.rotation += deltaTime * rotatableComponent.axis
            transformComponent.position -= deltaTime * rotatableComponent.axis
            
            do {
                let x = entity.getComponent(componentClass: BoundingBoxComponent.self) as! BoundingBoxComponent
                x.position -= deltaTime * rotatableComponent.axis
            }
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
