class EntityManager {
    private var entities: [Entity] = []
    private var entitySet = Set<Entity>()
    
    public func addEntity(entity: Entity) throws {
        if (entitySet.contains(entity)) {
            throw ECSError.EntityExists
        }
        
        entities.append(entity)
        entitySet.insert(entity)
    }
    
    public func removeEntity(entity: Entity) throws {
        if (!entitySet.contains(entity)) {
            throw ECSError.EntityDoesntExist
        }
        
        entitySet.remove(entity)
        entities.removeAll { (e) -> Bool in
            e == entity
        }
    }
    
    public func getEntities() -> [Entity] {
        return entities
    }
}
