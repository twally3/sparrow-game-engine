import Foundation

class Strength {
    private static func create(a: Float, b: Float, c: Float, w: Float = 1.0) -> Float {
        var result: Float = 0
        
        result += max(0, min(1000, a * w)) * 1000000
        result += max(0, min(1000, b * w)) * 1000
        result += max(0, min(1000, c * w))
        
        return result
    }
    
    public static let required = Strength.create(a: 1000, b: 1000, c: 1000)
    public static let strong = Strength.create(a: 1, b: 0, c: 0)
    public static let medium = Strength.create(a: 0, b: 1, c: 0)
    public static let weak = Strength.create(a: 0, b: 0, c: 1)
    
    public static func clip(value: Float) -> Float {
        return max(0, min(Strength.required, value))
    }
}
