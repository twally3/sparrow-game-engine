class Row {
    private var _constant: Float
    private var _cellMap = IndexedMap<Symbol, Float>()
    
    init(_ constant: Float = 0, cellMap: IndexedMap<Symbol, Float>? = nil) {
        self._constant = constant
        if let cellMap = cellMap {
            self._cellMap = cellMap
        }
    }
    
    public func insertRow(other: Row, coefficient: Float = 1.0) {
        self._constant += other.constant() * coefficient
        let cells = other.cellMap()
        
        for i in 0..<cells.size() {
            let pair = cells.item(at: i)
            self.insertSymbol(symbol: pair.first, coefficient: pair.second * coefficient)
        }
    }
    
    public func insertSymbol(symbol: Symbol, coefficient: Float = 1.0) {
        let pair = self._cellMap.setDefault(key: symbol, factory: { 0.0 })

        pair.second += coefficient

        if nearZero(value: pair.second) {
            _ = self._cellMap.erase(key: symbol)
        }
    }
    
    public func removeSymbol(symbol: Symbol) {
        _ = self._cellMap.erase(key: symbol)
    }
    
    public func reverseSign() {
        self._constant = -self._constant
        let cells = self._cellMap
        
        for i in 0..<cells.size() {
            let pair = cells.item(at: i)
            pair.second = -pair.second
        }
    }
    
    public func allDummies() -> Bool {
        let cells = self._cellMap
        for i in 0..<cells.size() {
            let pair = cells.item(at: i)
            if pair.first.type() != SymbolType.Dummy {
                return false
            }
        }
        
        return true
    }
    
    public func solveForEx(lhs: Symbol, rhs: Symbol) {
        self.insertSymbol(symbol: lhs, coefficient: -1)
        self.solve(for: rhs)
    }
    
    public func solve(for symbol: Symbol) {
        let cells = self._cellMap
        guard let pair = cells.erase(key: symbol) else { fatalError("Attemt to erase non existant key") }
        let coeff = -1.0 / pair.second
        
        self._constant *= coeff
        
        for i in 0..<cells.size() {
            cells.item(at: i).second *= coeff
        }
    }
    
    public func coefficient(for symbol: Symbol) -> Float {
        guard let pair = self._cellMap.find(key: symbol) else { return 0 }
        
        return pair.second
    }
    
    public func substitute(symbol: Symbol, row: Row) {
        if let pair = self._cellMap.erase(key: symbol) {
            self.insertRow(other: row, coefficient: pair.second)
        }
    }
    
    public func copy() -> Row {
        return Row(self._constant, cellMap: self._cellMap.copy())
    }
    
    public func add(value: Float) -> Float {
        self._constant += value
        return self._constant
    }
    
    public func constant() -> Float {
        return self._constant
    }
    
    public func isConstant() -> Bool {
        return self._cellMap.empty()
    }
    
    public func cellMap() -> IndexedMap<Symbol, Float> {
        return self._cellMap
    }
}
