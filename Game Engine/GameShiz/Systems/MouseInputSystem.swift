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
        let right = Mouse.isMouseButtonPressed(button: .RIGHT)
        let left = Mouse.isMouseButtonPressed(button: .LEFT)
        let centre = Mouse.isMouseButtonPressed(button: .CENTER)
        
        let dx = Mouse.getDX()
        let dy = Mouse.getDY()
        
        let dwheel = Mouse.getDWheel()
        
        for entity in entities {
            let mouseComp = entity.getComponent(componentClass: MouseInputComponent.self) as! MouseInputComponent
            
            mouseComp.right = right
            mouseComp.left = left
            mouseComp.centre = centre
            
            mouseComp.dx = dx
            mouseComp.dy = dy
            mouseComp.dwheel = dwheel
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
