import Foundation

class Constraint: Identifiable {
    private var _operator: Operator
    private var _strength: Float
    private var _expression: Expression
    
    private var _id: Int
    
    static var baseId: Int = 1
    
    init(expression: /*variable | */ Expression,
         oper: Operator,
         rhs: Expression? /*| Variable |  Float?*/,
         strength: Float = Strength.required) {
        
        self._operator = oper
        self._strength = Strength.clip(value: strength)
        self._expression = expression
        
        self._id = Constraint.baseId
        Constraint.baseId += 1
        
        if let rhs = rhs {
            self._expression = expression.minus(value: rhs)
        } else {
            self._expression = expression
        }
        
//        if rhs == nil && expression as? Expression != nil {
//            self._expression = expression
//        } else {
//            self._expression = expression.minus(rhs)
//        }
    }
    
    func op() -> Operator {
        return self._operator
    }
    
    func strength() -> Float {
        return self._strength
    }
    
    func expression() -> Expression {
        return self._expression
    }
    
    func id() -> Int {
        return self._id
    }
}
