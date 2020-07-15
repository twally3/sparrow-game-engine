class ParticleSystemRefComponent: Component {
    public var particleSystemComponent: ParticleSystemComponent
    
    init(particleSystemComponent: ParticleSystemComponent) {
        self.particleSystemComponent = particleSystemComponent
    }
}
