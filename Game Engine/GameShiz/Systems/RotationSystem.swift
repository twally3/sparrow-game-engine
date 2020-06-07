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
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            let rotatableComponent = entity.getComponent(componentClass: RotatableComponent.self) as! RotatableComponent
            
//            transformComponent.rotation += deltaTime * rotatableComponent.axis
//            transformComponent.position -= deltaTime * 0.25 * rotatableComponent.axis

//            print(sin(Double(time)) * 10)
            
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
                transformComponent.position.y += deltaTime * 2
            } else if Keyboard.isKeyPressed(.e) {
                transformComponent.position.y -= deltaTime * 2
            }
            
            time = time + deltaTime
            
//            transformComponent.scale += Float(sin(Double(time))) * 0.01
            
//            do {
//                let x = entity.getComponent(componentClass: BoundingBoxComponent.self) as! BoundingBoxComponent
//                x.position -= deltaTime * rotatableComponent.axis
//            }
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
