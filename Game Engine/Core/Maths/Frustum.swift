import simd

class Plane {
    var label: String = ""
    var n = SIMD3<Float>(0,0,0)
    var d: Float = 0
    
    init(_ label: String) {
        self.label = label
    }
    
    func normalize() {
        let scale = 1 / length(n)
        n *= scale
        d *= scale
    }
}

class Frustum: CustomStringConvertible {
    private var left = Plane("Left")
    private var right = Plane("Right")
    private var top = Plane("Top")
    private var bottom = Plane("Bottom")
    private var near = Plane("Near")
    private var far = Plane("Far")
    
    var description: String {
        return "LEFT: \(left.n)\nRIGHT: \(right.n)\nFAR  : \(far.n)\nNEAR : \(near.n)\nTOP   : \(top.n)\nBOTTOM : \(bottom.n)"
    }
    
    private var planes: [Plane] {
        return [left, right, top, bottom, near, far]
    }
    
    init() { }
    
    func update(pvMatrix: matrix_float4x4) {
        // column3 - column0
        right.n.x =   pvMatrix[0][3] - pvMatrix[0][0]
        right.n.y =   pvMatrix[1][3] - pvMatrix[1][0]
        right.n.z =   pvMatrix[2][3] - pvMatrix[2][0]
        right.d =     pvMatrix[3][3] - pvMatrix[3][0]
        right.normalize()
    
        // column0 + column3
        left.n.x =    pvMatrix[0][3] + pvMatrix[0][0]
        left.n.y =    pvMatrix[1][3] + pvMatrix[1][0]
        left.n.z =    pvMatrix[2][3] + pvMatrix[2][0]
        left.d =      pvMatrix[3][3] + pvMatrix[3][0]
        left.normalize()
        
        // column1 + column3
        bottom.n.x =  pvMatrix[0][3] + pvMatrix[0][1]
        bottom.n.y =  pvMatrix[1][3] + pvMatrix[1][1]
        bottom.n.z =  pvMatrix[2][3] + pvMatrix[2][1]
        bottom.d =    pvMatrix[3][3] + pvMatrix[3][1]
        bottom.normalize()
        
        // column3 - column1
        top.n.x =     pvMatrix[0][3] - pvMatrix[0][1]
        top.n.y =     pvMatrix[1][3] - pvMatrix[1][1]
        top.n.z =     pvMatrix[2][3] - pvMatrix[2][1]
        top.d =       pvMatrix[3][3] - pvMatrix[3][1]
        top.normalize()
    
        // column3 - column2
        far.n.x =     pvMatrix[0][3] - pvMatrix[0][2]
        far.n.y =     pvMatrix[1][3] - pvMatrix[1][2]
        far.n.z =     pvMatrix[2][3] - pvMatrix[2][2]
        far.d =       pvMatrix[3][3] - pvMatrix[3][2]
        far.normalize()
    
        // column2 + column3
        near.n.x =    pvMatrix[0][3] + pvMatrix[0][2]
        near.n.y =    pvMatrix[1][3] + pvMatrix[1][2]
        near.n.z =    pvMatrix[2][3] + pvMatrix[2][2]
        near.d =      pvMatrix[3][3] + pvMatrix[3][2]
        near.normalize()
    }
    
    func sphereIntersection(center: SIMD3<Float>, radius: Float)->Bool {
//        print("start intersection test -- radius: \(radius)")
        for p in planes {
            let val = dot(center, p.n) + p.d + radius
//            print("\(p.label): \(p.d)")
            if (val <= 0) {
//                print("\(p.label): Hit")
                return false;
            }
        }
//        print("end intersection test")
        return true
    }
}

