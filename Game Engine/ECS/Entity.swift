class Entity {
    private let components = Bag<Component>()
    private var componentsArray = Array<Component>()
    private let componentBits = Bits()
    private let familyBits = Bits()
    
    public let componentAdded = Event<Entity>()
    public let componentRemoved = Event<Entity>()
    
    public func add(component: Component) throws {
        let componentClass = type(of: component)
        let componentTypeIndex = ComponentType.getIndex(for: componentClass)
        
        if components.get(at: componentTypeIndex) != nil {
            throw ECSError.ComponentExistsOnEntity
        }
        
        components.set(index: componentTypeIndex, e: component)
        componentsArray.append(component)
        componentBits.set(at: componentTypeIndex);
        
        onComponentAdded()
    }
    
    public func remove(componentClass: Component.Type) throws {
        let componentTypeIndex = ComponentType.getIndex(for: componentClass)
        guard let _ = components.remove(at: componentTypeIndex) else {
            throw ECSError.ComponentDoesntExistOnEntity
        }
        componentsArray.removeAll { (c) -> Bool in
            type(of: c) == componentClass
        }
        componentBits.clear(at: componentTypeIndex)
        
        onComponentRemoved()
    }
    
    public func getFamilyBits() -> Bits {
        return familyBits
    }
    
    public func getComponentBits() -> Bits {
        return componentBits
    }
    
    public func getComponent<T: Component>(componentClass: T.Type) -> T? {
        let componentTypeIndex = ComponentType.getIndex(for: componentClass)
        return components.get(at: componentTypeIndex) as! T?
    }
    
    public func getComponent<T: Component>() -> T? {
        let componentTypeIndex = ComponentType.getIndex(for: T.self)
        return components.get(at: componentTypeIndex) as! T?
    }
    
    private func onComponentAdded() {
        componentAdded.raise(data: self)
    }
    
    private func onComponentRemoved() {
        componentRemoved.raise(data: self)
    }
}

extension Entity: Hashable {
    static func == (lhs: Entity, rhs: Entity) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
