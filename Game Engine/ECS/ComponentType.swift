class ComponentType {
    private static var assignedComponentTypes: [ObjectIdentifier : ComponentType] = [:]
    public static var typeIndex: Int = 0
    
    private var index: Int
    
    init() {
        index = ComponentType.typeIndex
        ComponentType.typeIndex += 1
    }
    
    public func getIndex() -> Int {
        return index
    }
    
    public static func getFor(componentType: Component.Type) -> ComponentType {
        if let type = assignedComponentTypes[componentType.classIdentifier] {
            return type
        }
        
        let type = ComponentType()
        assignedComponentTypes[componentType.classIdentifier] = type
        
        return type
    }
    
    public static func getIndex(for componentType: Component.Type) -> Int {
        return getFor(componentType: componentType).getIndex()
    }
    
    public static func getBits(for componentTypes: [Component.Type]) -> Bits {
        let bits = Bits()
        
        let typesLength = componentTypes.count
        for i in 0..<typesLength {
            bits.set(at: ComponentType.getIndex(for: componentTypes[i]))
        }
        
        return bits
    }
}
