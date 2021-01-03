class ViewConstraintEngine {
    private let solver = Solver()
    public var window: Window
    
    private var views: [View] = []
    private var viewMap: [Int : Int] = [:]
    
    private var constraintMap: [Int : [Constraint]] = [:]
    
    init(width: Float, height: Float) {
        self.window = Window(width: width, height: height)
        self.views.append(self.window)
    }
    
    func add(view: View) {
        if self.viewMap[view.id()] != nil { return }
        self.viewMap[view.id()] = self.views.count
        self.views.append(view)
    }
    
    func remove(view: View) {
        guard let viewIdx = self.viewMap[view.id()] else { return }

        self.viewMap.removeValue(forKey: view.id())

        let last = self.views.popLast()!

        if view.id() != last.id() {
            self.views[viewIdx] = last
            self.viewMap[last.id()] = viewIdx
        }
        
        if let existingConstraints = self.constraintMap.removeValue(forKey: view.id()) {
            for existingConstraint in existingConstraints {
                solver.removeConstraint(constraint: existingConstraint)
            }
        }
    }
    
    func update() {
        for view in views {
            if view.getConstraintsNeedsUpdating() {
                if let existingConstraints = self.constraintMap.removeValue(forKey: view.id()) {
                    for existingConstraint in existingConstraints {
                        solver.removeConstraint(constraint: existingConstraint)
                    }
                }
                
                view.doUpdateConstraints()
                
                let constraints = self.processConstraints(constraints: view.getConstraints())
                for constraint in constraints {
                    solver.addConstraint(constraint: constraint)
                }
                self.constraintMap[view.id()] = constraints
            }
        }
        
        solver.updateVariables()
        
        for view in views {
            view.render()
        }
    }
    
    public func processConstraints(constraints: [ViewConstraint]) -> [Constraint] {
        var _constraints: [Constraint] = []
        
        for constraint in constraints {
            let fromVar = getExpression(for: constraint.fromAttribute, view: constraint.fromItem)
            let oper = getOperator(for: constraint.relatedBy)
            var toVar: Expression
            
            if let toAttribute = constraint.toAttribute, let toItem = constraint.toitem {
                toVar = Expression(args: [constraint.multiplier, getExpression(for: toAttribute, view: toItem)], constraint.constant)
            } else {
                toVar = Expression(args: constraint.constant)
            }
            
            _constraints.append(
                Constraint(expression: fromVar,
                           oper: oper,
                           rhs: toVar,
                           strength: Strength.strong)
            )
        }
        
        return _constraints
    }
    
    private func getExpression(for anchor: AnchorTypes, view: View) -> Expression {
        switch anchor {
        case .top:
            return Expression(args: view.frame.minY)
        case .bottom:
            return Expression(args: view.frame.minY, view.frame.height)
        case .leading:
            return Expression(args: view.frame.minX)
        case .trailing:
            return Expression(args: view.frame.minX, view.frame.width)
        case .width:
            return Expression(args: view.frame.width)
        case .height:
            return Expression(args: view.frame.height)
        }
    }
    
    private func getOperator(for relation: AnchorRelations) -> Operator {
        switch relation {
        case .equal:
            return .Eq
        case .greaterThanOrEqual:
            return .Ge
        case .lessThanOrEqual:
            return .Le
        }
    }
}
