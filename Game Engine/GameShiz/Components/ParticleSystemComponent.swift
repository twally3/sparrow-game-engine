class ParticleSystemComponent: Component {
    var pps: Float = 5
    var averageSpeed: Float = 0.5 //25
    var averageLifeLength: Float = 0.5
    var averageScale: Float = 10
    
    var speedError: Float = 0
    var lifeError: Float = 0
    var scaleError: Float = 0
    
    var direction: SIMD3<Float>? = nil//SIMD3<Float>(0, 1, 0)
    var directionDeviation: Float = 0//0.1
    
    var randomRotation: Bool = true
    
    var textureRows: Int = 8
    
    init() {
        
    }
}
