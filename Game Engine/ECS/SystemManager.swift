class SystemManager {
    private var systemsByClass: [ObjectIdentifier : System] = [:]
    private var systems: [System] = []
    
    public func addSystem(system: System) throws {
        let systemType = type(of: system)
        
        // TODO: Consider replacing the old system with the new one
        if getSystem(type: systemType) != nil {
            throw ECSError.SystemsExists
        }
        
        systems.append(system)
        systemsByClass[systemType.classIdentifier] = system
        
        systems.sort { (a, b) -> Bool in
            a.priority < b.priority
        }
        
        systems.sort(by: { $0.priority < $1.priority })
    }
    
    public func getSystem(type: System.Type) -> System? {
        return systemsByClass[type.classIdentifier]
    }
    
    public func getSystems() -> [System] {
        return systems
    }
}
