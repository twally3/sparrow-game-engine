class ParticleComponent: Component {
    public var velocity: SIMD3<Float>
    public var gravityEffect: Float
    public var lifeLength: Float
    public var elapsedTime: Float = 0
    
    init(velocity: SIMD3<Float>, gravityEffect: Float, lifeLength: Float) {
        self.velocity = velocity
        self.gravityEffect = gravityEffect
        self.lifeLength = lifeLength
    }
}
