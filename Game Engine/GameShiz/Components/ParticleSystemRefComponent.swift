class ParticleSystemRefComponent: Component {
    public var particleSystemComponent: ParticleSystemComponent
    public var renderComponent: RenderComponent
    public var transformComponent: TransformComponent
    
    init(particleSystemComponent: ParticleSystemComponent, renderComponent: RenderComponent, transformComponent: TransformComponent) {
        self.particleSystemComponent = particleSystemComponent
        self.renderComponent = renderComponent
        self.transformComponent = transformComponent
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
