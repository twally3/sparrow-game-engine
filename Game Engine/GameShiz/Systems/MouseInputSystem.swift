import MetalKit

class MouseInputSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: MouseInputComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entity in entities {
            let mouseComp = entity.getComponent(componentClass: MouseInputComponent.self) as! MouseInputComponent
            
            mouseComp.right = Mouse.isMouseButtonPressed(button: .RIGHT)
            mouseComp.left = Mouse.isMouseButtonPressed(button: .LEFT)
            mouseComp.centre = Mouse.isMouseButtonPressed(button: .CENTER)
            
            mouseComp.dx = Mouse.getDX()
            mouseComp.dy = Mouse.getDY()
            mouseComp.dwheel = Mouse.getDWheel()
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
