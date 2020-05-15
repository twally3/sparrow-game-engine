class Bits {
    let bits = Bag<Bool>()
    
    public func set(at index: Int) {
        bits.set(index: index, e: true)
    }
    
    public func get(at index: Int) -> Bool {
        if let bit = bits.get(at: index) {
            return bit
        }
        
        return false
    }
    
    public func clear(at index: Int) {
        bits.set(index: index, e: false)
    }
    
    public func contains(all bits: Bits) -> Bool {
        var match = true
        
        for i in 0..<bits.getAll().count {
            let testBit = bits.get(at: i)
            if testBit == true && self.bits.get(at: i) != testBit {
                match = false
                break
            }
        }
        
        return match
    }
    
    public func getSize() -> Int {
        return bits.getSize()
    }
    
    public func getAll() -> ContiguousArray<Bool?> {
        return bits.getAll()
    }
    
    public func getString() -> String {
        var finalString = ""

        for thing in self.bits.getAll() {
            finalString.append(thing == true ? "1" : "0")
        }
        
        return finalString
    }
}
