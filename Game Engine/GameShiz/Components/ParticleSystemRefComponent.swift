class ParticleSystemRefComponent: Component {
    public var particleSystemComponent: ParticleSystemComponent
    public var renderComponent: RenderComponent
    
    init(particleSystemComponent: ParticleSystemComponent, renderComponent: RenderComponent) {
        self.particleSystemComponent = particleSystemComponent
        self.renderComponent = renderComponent
    }
}

extension ParticleSystemRefComponent: Hashable {
    static func == (lhs: ParticleSystemRefComponent, rhs: ParticleSystemRefComponent) -> Bool {
        return lhs.particleSystemComponent === rhs.particleSystemComponent
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self.particleSystemComponent))
    }
}
