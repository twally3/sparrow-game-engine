class Family {
    private static var familyIndex: Int = 0
    
    private var index: Int
    private var all: Bits
    private var _hash: String
    
    public var hash: String {
        get {
            return _hash
        }
    }
    
    private init(all: Bits) {
        self.index = Family.familyIndex
        self.all = all
        Family.familyIndex += 1
        
        self._hash = all.getString()
    }
    
    public func getIndex() -> Int {
        return index
    }
    
    public func matches(entity: Entity) -> Bool {
        let entityComponentBits = entity.getComponentBits()
        
        if !entityComponentBits.contains(all: all) {
            return false
        }
        
        return true
    }
    
    public static func all(components: Component.Type...) -> Family {
        return Family(all: ComponentType.getBits(for: components))
    }
    
    public func getBits() -> Bits {
        return all
    }
}

extension Family: Hashable {
    static func == (lhs: Family, rhs: Family) -> Bool {
        return lhs._hash == rhs._hash
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.hash)
    }
}
