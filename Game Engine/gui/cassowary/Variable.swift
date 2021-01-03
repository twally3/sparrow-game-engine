import Foundation

class Variable: Identifiable {
    private var _id: Int
    private var _name: String
    private var _value: Float = 0
    
    static var baseId = 0
    
    init(name: String) {
        self._id = Variable.nextId()
        self._name = name
    }
    
    func setValue(value: Float) {
        self._value = value
    }
    
    func value() -> Float {
        return self._value
    }
    
    func name() -> String {
        return self._name
    }
    
    func id() -> Int {
        return self._id
    }
    
    private static func nextId() -> Int {
        Variable.baseId += 1
        return Variable.baseId
    }
}
