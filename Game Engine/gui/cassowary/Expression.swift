import Foundation

class Expression {
    private var _constant: Float
    private var _terms: IndexedMap<Variable, Float>
    
    init(args: Any...) {
        let parsed = Expression.parseArgs(args: args)
        self._terms = parsed.0
        self._constant = parsed.1
    }
    
    func constant() -> Float {
        return self._constant
    }
    
    func terms() -> IndexedMap<Variable, Float> {
        return self._terms
    }
    
    func minus(value: Expression) -> Expression {
        return Expression(args: self, [Float(-1), value])
    }
    
    private static func parseArgs(args: [Any]) -> (IndexedMap<Variable, Float>, Float) {
        var constant: Float = 0.0
        let factory: () -> Float = { 0.0 }
        let terms = IndexedMap<Variable, Float>()
        
        for i in 0..<args.count {
            if let item = args[i] as? Float {
                constant += item
            } else if let item = args[i] as? Variable {
                terms.setDefault(key: item, factory: factory).second += 1
            } else if let item = args[i] as? Expression {
                constant += item.constant()
                let terms2 = item.terms()
                
                for j in 0..<terms2.size() {
                    let termPair = terms2.item(at: j)
                    terms.setDefault(key: termPair.first, factory: factory).second += termPair.second
                }
            } else if let item = args[i] as? Array<Any> {
                if item.count != 2 {
                    fatalError("Array must have a length of 2")
                }
                
                guard let value = item[0] as? Float else { fatalError("Array item 0 must be a float") }
                
                if let value2 = item[1] as? Variable {
                    terms.setDefault(key: value2, factory: factory).second += value
                } else if let value2 = item[1] as? Expression {
                    constant += (value2.constant() * value)
                    let terms2 = value2.terms()
                    
                    for j in 0..<terms2.size() {
                        let termPair = terms2.item(at: j)
                        terms.setDefault(key: termPair.first, factory: factory).second += (termPair.second * value)
                    }
                } else {
                    fatalError("Array item 1 must be a variable or expression")
                }
            } else {
                fatalError("Invalid runtime type passed to Expression")
            }
        }
        
        return (terms, constant)
    }
}
