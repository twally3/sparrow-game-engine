import Foundation

class Solver {
    private var cnMap = IndexedMap<Constraint, Tag>()
    private var varMap = IndexedMap<Variable, Symbol>()
    private var rowMap = IndexedMap<Symbol, Row>()
    private var editMap = IndexedMap<Variable, EditInfo>()
    private var objective = Row()
    private var artificial: Row? = nil
    private var infeasableRows: [Symbol] = []
       
    public func addConstraint(constraint: Constraint) {
        if self.cnMap.find(key: constraint) != nil { fatalError("Duplicate constraint") }
        
        let data = self.createRow(constraint: constraint)
        let row = data.row
        let tag = data.tag
        var subject = self.chooseSubject(row: row, tag: tag)
        
        if subject.type() == .Invalid && row.allDummies() {
            if !nearZero(value: row.constant()) {
                fatalError("Unsatisfiable Constraint!")
            } else {
                subject = tag.marker
            }
        }
        
        if subject.type() == .Invalid {
            if !self.addWithArtificialVariable(row: row) {
                fatalError("Unsatisfiable Constraint!")
            }
        } else {
            row.solve(for: subject)
            self.substitute(symbol: subject, row: row)
            _ = self.rowMap.insert(key: subject, value: row)
        }
        
        _ = self.cnMap.insert(key: constraint, value: tag)
        
        self.optimise(objective: self.objective)
    }
    
    public func removeConstraint(constraint: Constraint) {
        guard let cnPair = self.cnMap.erase(key: constraint) else { fatalError("Unknown Constraint") }
        
        self.removeConstraintEffects(constraint: constraint, tag: cnPair.second)
        
        let marker = cnPair.second.marker
        if self.rowMap.erase(key: marker) == nil {
            let leaving = self.getMarkerLeavingSymbol(marker: marker)
            
            if leaving.type() == .Invalid {
                fatalError("Failed to find leaving row")
            }
            
            let pair = self.rowMap.erase(key: leaving)!
            pair.second.solveForEx(lhs: leaving, rhs: marker)
            self.substitute(symbol: marker, row: pair.second)
        }
        
        self.optimise(objective: self.objective)
    }
    
    public func addEditVariable(variable: Variable, strength: Float) {
        if self.editMap.find(key: variable) != nil { fatalError("Duplicate edit variable") }
        
        let _strength = Strength.clip(value: strength)
        if _strength == Strength.required {
            fatalError("Bad required strength")
        }
        
        let expr = Expression(args: variable)
        let cn = Constraint(expression: expr, oper: Operator.Eq, rhs: nil, strength: strength)
        
        self.addConstraint(constraint: cn)
        
        guard let tag = self.cnMap.find(key: cn)?.second else { fatalError("Missing constraint THIS SHOULDNT HAPPEN!") }
        let info = EditInfo(tag: tag, constraint: cn, constant: 0)
        _ = self.editMap.insert(key: variable, value: info)
    }
    
    public func suggestValue(variable: Variable, value: Float) {
        guard let editPair = self.editMap.find(key: variable) else { fatalError("Unknown edit variable") }
        
        let rows = self.rowMap
        let info = editPair.second
        let delta = value - info.constant
        
        info.constant = value
        
        let marker = info.tag.marker
        if let rowPair = rows.find(key: marker) {
            if rowPair.second.add(value: -delta) < 0 {
                self.infeasableRows.append(marker)
            }
            
            self.dualOptimise()
            return
        }
        
        let other = info.tag.other
        if let rowPair = rows.find(key: other) {
            if rowPair.second.add(value: delta) < 0 {
                self.infeasableRows.append(other)
            }
            
            self.dualOptimise()
            return
        }
        
        for i in 0..<rows.size() {
            let rowPair = rows.item(at: i)
            let row = rowPair.second
            let coeff = row.coefficient(for: marker)
            
            if coeff != 0 && row.add(value: delta * coeff) < 0 && rowPair.first.type() != .External {
                self.infeasableRows.append(rowPair.first)
            }
        }
        self.dualOptimise()
    }
    
    public func updateVariables() {
        let vars = self.varMap
        let rows = self.rowMap
        
        for i in 0..<vars.size() {
            let pair = vars.item(at: i)
            if let rowPair = rows.find(key: pair.second) {
                pair.first.setValue(value: rowPair.second.constant())
            } else {
                pair.first.setValue(value: 0.0)
            }
        }
    }
    
    private func createRow(constraint: Constraint) -> RowCreation {
        let expr = constraint.expression()
        let row = Row(expr.constant())
        
        let terms = expr.terms()
        
        for i in 0..<terms.size() {
            let termPair = terms.item(at: i)
            
            if !nearZero(value: termPair.second) {
                let symbol = self.getVarSymbol(variable: termPair.first)
                if let basicPair = self.rowMap.find(key: symbol) {
                    row.insertRow(other: basicPair.second, coefficient: termPair.second)
                } else {
                    row.insertSymbol(symbol: symbol, coefficient: termPair.second)
                }
            }
        }
        
        let objective = self.objective
        let strength = constraint.strength()
        let tag = Tag(marker: Symbol.INVALID_SYMBOL, other: Symbol.INVALID_SYMBOL)
        
        switch constraint.op() {
        case Operator.Le, Operator.Ge:
            let coeff: Float = constraint.op() == Operator.Le ? 1 : -1
            let slack = self.makeSymbol(type: SymbolType.Slack)
            
            tag.marker = slack
            
            row.insertSymbol(symbol: slack, coefficient: coeff)
            
            if strength < Strength.required {
                let error = self.makeSymbol(type: SymbolType.Error)
                tag.other = error
                row.insertSymbol(symbol: error, coefficient: -coeff)
                objective.insertSymbol(symbol: error, coefficient: strength)
            }
            
            break
        case Operator.Eq:
            if strength < Strength.required {
                let errplus = self.makeSymbol(type: SymbolType.Error)
                let errminus = self.makeSymbol(type: SymbolType.Error)
                
                tag.marker = errplus
                tag.other = errminus
                
                row.insertSymbol(symbol: errplus, coefficient: -1)
                row.insertSymbol(symbol: errminus, coefficient: 1)
                
                objective.insertSymbol(symbol: errplus, coefficient: strength)
                objective.insertSymbol(symbol: errminus, coefficient: strength)
            } else {
                let dummy = self.makeSymbol(type: SymbolType.Dummy)
                tag.marker = dummy
                row.insertSymbol(symbol: dummy)
            }
            
            break
        }
        
        if row.constant() < 0 {
            row.reverseSign()
        }
        
        return RowCreation(row: row, tag: tag)
    }
    
    private func chooseSubject(row: Row, tag: Tag) -> Symbol {
        let cells = row.cellMap()
        
        for i in 0..<cells.size() {
            let pair = cells.item(at: i)
            if pair.first.type() == SymbolType.External { return pair.first }
        }
        
        var type = tag.marker.type()
        if type == SymbolType.Slack || type == SymbolType.Error {
            if row.coefficient(for: tag.marker) < 0 {
                return tag.marker
            }
        }
        
        type = tag.other.type()
        if type == SymbolType.Slack || type == SymbolType.Error {
            if row.coefficient(for: tag.other) < 0 {
                return tag.other
            }
        }
        
        return Symbol.INVALID_SYMBOL
    }
    
    private func addWithArtificialVariable(row: Row) -> Bool {
        let art = self.makeSymbol(type: SymbolType.Slack)
        _ = self.rowMap.insert(key: art, value: row.copy())
        self.artificial = row.copy()
        
        self.optimise(objective: self.artificial!)
        let success = nearZero(value: self.artificial!.constant())
        self.artificial = nil
        
        if let pair = self.rowMap.erase(key: art) {
            let basicRow = pair.second
            
            if basicRow.isConstant() {
                return success
            }
            
            let entering = self.anyPivotableSymbol(row: basicRow)
            if entering.type() == .Invalid {
                return false // TODO: Work out if this is even possible
            }
            
            basicRow.solveForEx(lhs: art, rhs: entering)
            self.substitute(symbol: entering, row: basicRow)
            _ = self.rowMap.insert(key: entering, value: basicRow)
        }
        
        let rows = self.rowMap
        for i in 0..<rows.size() {
            rows.item(at: i).second.removeSymbol(symbol: art)
        }
        
        self.objective.removeSymbol(symbol: art)
        return success
    }
    
    private func substitute(symbol: Symbol, row: Row) {
        let rows = self.rowMap
        
        for i in 0..<rows.size() {
            let pair = rows.item(at: i)
            pair.second.substitute(symbol: symbol, row: row)
            
            if pair.second.constant() < 0 && pair.first.type() != .External {
                self.infeasableRows.append(pair.first)
            }
        }
        
        self.objective.substitute(symbol: symbol, row: row)
        self.artificial?.substitute(symbol: symbol, row: row)
    }
    
    private func optimise(objective: Row) {
        while true {
            let entering = self.getEnteringSymbol(objective: objective)
            
            if entering.type() == .Invalid { return }
            
            let leaving = self.getLeavingSymbol(entering: entering)
            if leaving.type() == .Invalid { fatalError("The objective is unbounded") }
            
            // TODO: Look into the conditional nature of this more
            guard let row = self.rowMap.erase(key: leaving)?.second else { return }
            
            row.solveForEx(lhs: leaving, rhs: entering)
            self.substitute(symbol: entering, row: row)
            _ = self.rowMap.insert(key: entering, value: row)
        }
    }
    
    private func dualOptimise() {
        while self.infeasableRows.count != 0 {
            let leaving = self.infeasableRows.popLast()!
            if let pair = self.rowMap.find(key: leaving) {
                if pair.second.constant() < 0 {
                    let entering = self.getDualEnteringSymbol(row: pair.second)
                    
                    if entering.type() == .Invalid {
                        fatalError("Dual optimise failed")
                    }
                    
                    let row = pair.second
                    _ = self.rowMap.erase(key: leaving)
                    row.solveForEx(lhs: leaving, rhs: entering)
                    self.substitute(symbol: entering, row: row)
                    _ = self.rowMap.insert(key: entering, value: row)
                }
            }
        }
    }
    
    private func getEnteringSymbol(objective: Row) -> Symbol {
        let cells = objective.cellMap()
        for i in 0..<cells.size() {
            let pair = cells.item(at: i)
            let symbol = pair.first
            
            if pair.second < 0 && symbol.type() != SymbolType.Dummy {
                return symbol
            }
        }
        
        return Symbol.INVALID_SYMBOL
    }
    
    private func getDualEnteringSymbol(row: Row) -> Symbol {
        var ratio = MAXFLOAT
        var entering = Symbol.INVALID_SYMBOL
        let cells = row.cellMap()
        
        for i in 0..<cells.size() {
            let pair = cells.item(at: i)
            let symbol = pair.first
            let c = pair.second
            
            if (c > 0 && symbol.type() != .Dummy) {
                let coeff = self.objective.coefficient(for: symbol)
                let r = coeff / c
                
                if r < ratio {
                    ratio = r
                    entering = symbol
                }
            }
        }
        
        return entering
    }
    
    private func getLeavingSymbol(entering: Symbol) -> Symbol {
        var ratio = MAXFLOAT
        var found = Symbol.INVALID_SYMBOL
        let rows = self.rowMap
        
        for i in 0..<rows.size() {
            let pair = rows.item(at: i)
            let symbol = pair.first
            
            if (symbol.type() != .External) {
                let row = pair.second
                let temp = row.coefficient(for: entering)
                
                if temp < 0 {
                    let tempRatio = -row.constant() / temp
                    if tempRatio < ratio {
                        ratio = tempRatio
                        found = symbol
                    }
                }
            }
        }
        
        return found
    }
    
    func anyPivotableSymbol(row: Row) -> Symbol {
        let cells = row.cellMap()
        
        for i in 0..<cells.size() {
            let pair = cells.item(at: i)
            let type = pair.first.type()
            
            if type == .Slack || type == .Error {
                return pair.first
            }
        }
        
        return Symbol.INVALID_SYMBOL
    }
    
    private func getMarkerLeavingSymbol(marker: Symbol) -> Symbol {
        let dmax = MAXFLOAT
        var r1 = dmax
        var r2 = dmax
        let invalid = Symbol.INVALID_SYMBOL
        var first = invalid
        var second = invalid
        var third = invalid
        let rows = self.rowMap
        
        for i in 0..<rows.size() {
            let pair = rows.item(at: i)
            let row = pair.second
            let c = row.coefficient(for: marker)
            
            if c == 0 { continue }
            
            let symbol = pair.first
            
            if symbol.type() == .External {
                third = symbol
            } else if c < 0 {
                let r = -row.constant() / c
                
                if r < r1 {
                    r1 = r
                    first = symbol
                }
            } else {
                let r = row.constant() / c
                
                if r < r2 {
                    r2 = r
                    second = symbol
                }
            }
        }
        
        if first !== invalid { return first }
        if second !== invalid { return second }
        return third
    }
    
    private func removeConstraintEffects(constraint: Constraint, tag: Tag) {
        if tag.marker.type() == .Error {
            self.removeMarkerEffects(marker: tag.marker, strength: constraint.strength())
        }
        
        if tag.other.type() == .Error {
            self.removeMarkerEffects(marker: tag.other, strength: constraint.strength())
        }
    }
    
    private func removeMarkerEffects(marker: Symbol, strength: Float) {
        if let pair = self.rowMap.find(key: marker) {
            self.objective.insertRow(other: pair.second, coefficient: -strength)
        } else {
            self.objective.insertSymbol(symbol: marker, coefficient: -strength)
        }
    }
    
    private func getVarSymbol(variable: Variable) -> Symbol {
        let factory: () -> Symbol = { self.makeSymbol(type: SymbolType.External) }
        return self.varMap.setDefault(key: variable, factory: factory).second
    }
    
    private func makeSymbol(type: SymbolType) -> Symbol {
        return Symbol(type: type)
    }
    
    class Tag {
        public var marker: Symbol
        public var other: Symbol
        
        init(marker: Symbol, other: Symbol) {
            self.marker = marker
            self.other = other
        }
    }

    class EditInfo {
        var tag: Tag
        var constraint: Constraint
        var constant: Float
        
        init(tag: Tag, constraint: Constraint, constant: Float) {
            self.tag = tag
            self.constraint = constraint
            self.constant = constant
        }
    }

    class RowCreation {
        public var row: Row
        public var tag: Tag
        
        init(row: Row, tag: Tag) {
            self.row = row
            self.tag = tag
        }
    }
}
