import Foundation

class IndexedMap<T : Identifiable, U> {
    var index: [Int: Int] = [:]
    var array: [Pair<T, U>] = []
    
    func insert(key: T, value: U) -> Pair<T, U> {
        let pair = Pair(key, value)
        
        if let i = self.index[key.id()] {
            self.array[i] = pair
        } else {
            self.index[key.id()] = self.array.count
            self.array.append(pair)
        }
        
        return pair
    }
    
    func find(key: T) -> Pair<T, U>? {
        if let i = self.index[key.id()] {
            return self.array[i]
        }

        return nil
    }
    
    func size() -> Int {
        return self.array.count
    }
    
    func empty() -> Bool {
        return self.array.count == 0
    }
    
    func item(at index: Int) -> Pair<T, U> {
        return self.array[index]
    }
    
    func setDefault(key: T, factory: () -> U) -> Pair<T, U> {
        if let i = self.index[key.id()] {
            return self.array[i]
        }
        
        let pair = Pair(key, factory())
        self.index[key.id()] = self.array.count
        self.array.append(pair)
        return pair
    }
    
    func erase(key: T) -> Pair<T, U>? {
        guard let i = self.index[key.id()] else { return nil }
        
        self.index.removeValue(forKey: key.id())
        let pair = self.array[i]
        
        // TODO: Maybe handle this better as it should never happen
        guard let last = self.array.popLast() else { return nil }
        
        if pair != last {
            self.array[i] = last
            self.index[last.first.id()] = i
        }
        
        return pair
    }
    
    func copy() -> IndexedMap<T, U> {
        let copy = IndexedMap<T, U>()
        for i in 0..<self.array.count {
            let oldPair = self.array[i]
            let pair = Pair(oldPair.first, oldPair.second)
            copy.array.append(pair)
            copy.index[pair.first.id()] = i
        }
        return copy
    }
}

class Pair<T, U>: NSObject {
    var first: T
    var second: U
    
    init(_ first: T, _ second: U) {
        self.first = first
        self.second = second
    }
}

