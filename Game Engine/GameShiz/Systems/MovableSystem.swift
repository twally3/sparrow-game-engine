import MetalKit

class MovableSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    var time: Float = 0
    
    let family = Family.all(components: TransformComponent.self, MovableComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entity in entities {
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
            
            if Keyboard.isKeyPressed(.upArrow) {
                transformComponent.position.z -= deltaTime * 2
            } else if Keyboard.isKeyPressed(.downArrow) {
                transformComponent.position.z += deltaTime * 2
            }
            
            if Keyboard.isKeyPressed(.leftArrow) {
                transformComponent.position.x -= deltaTime * 2
            } else if Keyboard.isKeyPressed(.rightArrow) {
                transformComponent.position.x += deltaTime * 2
            }
            
            if Keyboard.isKeyPressed(.q) {
                if let rigidbodyComponent = entity.getComponent(componentClass: RigidbodyComponent.self) {
                    rigidbodyComponent.forces.append(SIMD3<Float>(0, 100, 0))
                } else {
                    transformComponent.position.y += deltaTime * 2
                }
            } else if Keyboard.isKeyPressed(.e) {
                transformComponent.position.y -= deltaTime * 2
            }
            
            time = time + deltaTime
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
