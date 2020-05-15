class Bag<T> {
    private var data: ContiguousArray<T?>
    private var size: Int = 0
    
    init() {
        data = ContiguousArray(repeating: nil, count: 64)
    }
    
    public func set(index: Int, e: T) {
        if index >= data.count {
            grow(size: index * 2)
        }
        
        size = index + 1
        data[index] = e
    }
    
    public func get(at index: Int) -> T? {
        return data[index]
    }
    
    public func getAll() -> ContiguousArray<T?> {
        return data
    }
    
    public func getSize() -> Int {
        return size
    }
    
    public func remove(at index: Int) -> T? {
        let x = data[index]
        size -= 1
        data[index] = data[size]
        data[size] = nil
        return x
    }
    
    private func grow(size: Int) {
        let oldData = data
        data = ContiguousArray(repeating: nil, count: size)
        data[0..<oldData.count] = oldData[0..<oldData.count]
    }
}
