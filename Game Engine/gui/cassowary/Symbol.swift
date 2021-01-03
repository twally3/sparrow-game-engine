class Symbol: Identifiable {
    private var _id: Int
    private var _type: SymbolType
    
    static var baseId = 0
    
    init(type: SymbolType, id: Int? = nil) {
        self._type = type
        self._id = id == nil ? Symbol.nextId() : id!
    }
    
    func id() -> Int {
        return self._id
    }
    
    func type() -> SymbolType {
        return self._type
    }
    
    private static func nextId() -> Int {
        Symbol.baseId += 1
        return Symbol.baseId
    }
    
    public static let INVALID_SYMBOL = Symbol(type: SymbolType.Invalid, id: -1)
}

enum SymbolType {
    case External
    case Slack
    case Invalid
    case Error
    case Dummy
}
