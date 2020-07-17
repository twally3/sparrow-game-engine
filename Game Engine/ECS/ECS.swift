import MetalKit

class ECS {
    let systemManager = SystemManager()
    let entityManager = EntityManager()
    var familyManager: FamilyManager
    
    var entityHandlers = Dictionary<Entity, (Disposable, Disposable)>()
    
    init() {
        self.familyManager = FamilyManager(entities: entityManager.getEntities())
    }
    
    public func createEntity() -> Entity {
        return Entity()
    }
    
    public func addEntity(entity: Entity) throws {
        try entityManager.addEntity(entity: entity)
        
        // CUSTOM
        let addedHandler = entity.componentAdded.addHandler(handler: onComponentAdded(entity:))
        let removedHandler = entity.componentRemoved.addHandler(handler: onComponentRemoved(entity:))
        entityHandlers[entity] = (addedHandler, removedHandler)
        
        // CUSTOM
        familyManager.onEntityAdded(entity: entity)
        // CUSTOM
        for system in systemManager.getSystems() {
            system.onEntityAdded(entity: entity)
        }
    }
    
    public func removeEntity(entity: Entity) throws {
        try entityManager.removeEntity(entity: entity)
        
        if let handlers = entityHandlers[entity] {
            handlers.0.dispose()
            handlers.1.dispose()
        }
        
        familyManager.onEntityRemoved(entity: entity)
        
        for system in systemManager.getSystems() {
            system.onEntityRemoved(entity: entity)
        }
    }
    
    public func getEntities(for family: Family) -> [Entity] {
        return familyManager.getEntites(for: family)
    }
    
    public func addSystem(system: System) throws {
        try systemManager.addSystem(system: system)
        
        onSystemAdded(system: system)
    }
    
    public func update(deltaTime: Float) {
        let systems = systemManager.getSystems()
        
        for system in systems {
            system.update(deltaTime: deltaTime)
        }
    }
    
    public func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        let systems = systemManager.getSystems()
        
        for system in systems {
            system.render(renderCommandEncoder: renderCommandEncoder)
        }
    }
    
    // -- Events --
    
    private func onSystemAdded(system: System) {
        system.onAddedToEngine(engine: self)
    }
    
    private func onComponentAdded(entity: Entity) {
        familyManager.updateFamilyMembership(entity: entity)
        
        for system in systemManager.getSystems() {
            system.onEntityAdded(entity: entity)
        }
    }
    
    private func onComponentRemoved(entity: Entity) {
        familyManager.updateFamilyMembership(entity: entity)
        
        for system in systemManager.getSystems() {
            system.onEntityRemoved(entity: entity)
        }
    }
}

enum ECSError: Error {
    case SystemsExists
    case EntityExists
    case EntityDoesntExist
    case ComponentExistsOnEntity
    case ComponentDoesntExistOnEntity
}
