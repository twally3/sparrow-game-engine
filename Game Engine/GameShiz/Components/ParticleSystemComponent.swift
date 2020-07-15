class ParticleSystemComponent: Component {
    let pps: Float = 5
    let averageSpeed: Float = 0.5 //25
    let averageLifeLength: Float = 0.5
    let averageScale: Float = 10
    
    let speedError: Float = 0
    let lifeError: Float = 0
    let scaleError: Float = 0
    
    let direction: SIMD3<Float>? = nil//SIMD3<Float>(0, 1, 0)
    let directionDeviation: Float = 0//0.1
    
    let randomRotation: Bool = true
    
    let textureRows: Int = 8
    
    init() {
        
    }
}
