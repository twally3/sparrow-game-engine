import MetalKit

class RotationSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    var time: Float = 0
    
    let family = Family.all(components: TransformComponent.self, RotatableComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entity in entities {
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
            let rotatableComponent = entity.getComponent(componentClass: RotatableComponent.self)!
            
            if rotatableComponent.isMouseControlled {
                if (Mouse.isMouseButtonPressed(button: .LEFT)) {
                    guard let mouseInputComponent = entity.getComponent(componentClass: MouseInputComponent.self) else { continue }
                    transformComponent.rotation.x += deltaTime * mouseInputComponent.dy
                    transformComponent.rotation.y += deltaTime * mouseInputComponent.dx
                }
            } else {
                transformComponent.rotation += deltaTime * rotatableComponent.axis
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
