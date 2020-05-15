class FamilyManager {
    // TODO: Just fucking get rid of this
    var entities: [Entity]
    
    private var entityListenerMasks = Dictionary<Family, Bits>()
    private var families = Dictionary<Family, Array<Entity>>()
    
    init(entities: [Entity]) {
        self.entities = entities
    }
    
    public func getEntites(for family: Family) -> [Entity] {
        return register(family: family)
    }
    
    private func register(family: Family) -> [Entity] {
        if let entitiesInFamily = families[family] {
            return entitiesInFamily
        }
        
        families[family] = []
        entityListenerMasks[family] = Bits()
        
        for entity in entities {
            updateFamilyMembership(entity: entity)
        }
        
        return families[family]!
    }
    
    public func updateFamilyMembership(entity: Entity, removed: Bool = false) {
        // TODO: this needs to be looked at later
        for (family, _) in entityListenerMasks {
            let familyIndex = family.getIndex()
            let entityFamilyBits = entity.getFamilyBits()
            
            let belongsToFamily = entityFamilyBits.get(at: familyIndex)
            let matches = family.matches(entity: entity) && !removed
            
            if (belongsToFamily != matches) {
                if matches {
                    families[family, default: []].append(entity)
                    entityFamilyBits.set(at: familyIndex)
                } else {
                    families[family, default: []].removeAll { (_entity) -> Bool in
                        entity === _entity
                    }
                    entityFamilyBits.clear(at: familyIndex)
                }
            }
        }
    }
    
    // CUSTOM
    public func onEntityAdded(entity: Entity) {
        entities.append(entity)
        updateFamilyMembership(entity: entity)
    }
    
    public func onEntityRemoved(entity: Entity) {
        entities.removeAll { (e) -> Bool in
            e == entity
        }
        
        updateFamilyMembership(entity: entity, removed: true)
    }
}
