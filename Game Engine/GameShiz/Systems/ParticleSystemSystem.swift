import MetalKit

class ParticleSystemSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    var time: Float = 0
    
    let family = Family.all(components: TransformComponent.self, ParticleSystemComponent.self, RenderComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entity in entities {
            let particleSystemComponent = entity.getComponent(componentClass: ParticleSystemComponent.self)!
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
            let renderComponent = entity.getComponent(componentClass: RenderComponent.self)!
            
            let particlesToCreate = particleSystemComponent.pps * deltaTime
            let count = Int(floor(particlesToCreate))
            let partialParticle = particlesToCreate.truncatingRemainder(dividingBy: 1)

            for _ in 0..<count {
                emitParticle(centre: transformComponent.position, particleSystemComponent: particleSystemComponent, renderComponent: renderComponent, transformComponent: transformComponent)
            }

            if Float.random(in: 0...1) < partialParticle {
                emitParticle(centre: transformComponent.position, particleSystemComponent: particleSystemComponent, renderComponent: renderComponent, transformComponent: transformComponent)
            }
        }
    }
    
    private func emitParticle(centre: SIMD3<Float>, particleSystemComponent: ParticleSystemComponent, renderComponent: RenderComponent, transformComponent: TransformComponent) {
        var velocity: SIMD3<Float>
        
        if let direction = particleSystemComponent.direction {
            velocity = generateRandomUnitVectorWithinCone(direction: direction,
                                                          deviation: particleSystemComponent.directionDeviation)
        } else {
            velocity = generateRandomUnitVector()
        }
        
        velocity = normalize(velocity) * generateValue(average: particleSystemComponent.averageSpeed, errorMargin: particleSystemComponent.speedError)
        let scale = generateValue(average: particleSystemComponent.averageScale, errorMargin: particleSystemComponent.scaleError)
        let lifeLength = generateValue(average: particleSystemComponent.averageLifeLength, errorMargin: particleSystemComponent.lifeError)
        
        // ----------
        
        let particle = engine.createEntity()
        try! particle.add(component: TransformComponent(position: centre,
                                                        rotation: SIMD3<Float>(0, 0, generateRotation(randomRotation: particleSystemComponent.randomRotation)),
                                                        scale: SIMD3<Float>(repeating: 0.05) * scale))
        try! particle.add(component: RenderComponent(mesh: Entities.meshes[.Quad], textureType: .Particle_Fire))
        try! particle.add(component: ParticleSystemRefComponent(particleSystemComponent: particleSystemComponent, renderComponent: renderComponent, transformComponent: transformComponent))
        try! particle.add(component: ParticleComponent(velocity: velocity, gravityEffect: 10, lifeLength: lifeLength))
        try! engine.addEntity(entity: particle)
    }
    
    // TODO: Actually implement me
    private func generateRandomUnitVectorWithinCone(direction: SIMD3<Float>, deviation: Float) -> SIMD3<Float> {
        return normalize(direction)
    }
    
    private func generateRandomUnitVector() -> SIMD3<Float> {
        return normalize(SIMD3<Float>.random(in: -1...1))
    }
    
    private func generateValue(average: Float, errorMargin: Float) -> Float {
        return average + Float.random(in: -1...1) * errorMargin
    }
    
    private func generateRotation(randomRotation: Bool) -> Float {
        return randomRotation ? Float.random(in: 0...Float.pi * 2) : 0
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {}
    
    func onEntityAdded(entity: Entity) {
        if family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
        }
    }
    
    func onEntityRemoved(entity: Entity) {
        if !family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
        }
    }
    
    func onAddedToEngine(engine: ECS) {
        self.entities = engine.getEntities(for: family)
        self.engine = engine
    }
}
