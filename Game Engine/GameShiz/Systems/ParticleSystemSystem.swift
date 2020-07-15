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
            
            let particlesToCreate = particleSystemComponent.pps * deltaTime
            let count = Int(floor(particlesToCreate))
            let partialParticle = particlesToCreate.truncatingRemainder(dividingBy: 1)

            for _ in 0..<count {
                emitParticle(centre: transformComponent.position, particleSystemComponent: particleSystemComponent)
            }

            if Float.random(in: 0...1) < partialParticle {
                emitParticle(centre: transformComponent.position, particleSystemComponent: particleSystemComponent)
            }
        }
    }
    
    private func emitParticle(centre: SIMD3<Float>, particleSystemComponent: ParticleSystemComponent) {
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
        try! particle.add(component: ParticleSystemRefComponent(particleSystemComponent: particleSystemComponent))
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
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
//        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Particle])
//        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Particle])
//
//        // TODO: Move me so I dont get fetched each time
//        let cameras = engine.getEntities(for: Family.all(components: CameraComponent.self))
//        let camera = cameras[0]
//        let cameraComponent = camera.getComponent(componentClass: CameraComponent.self)!
//        let viewMatrix = cameraComponent.viewMatrix
//
//        for entity in entities {
//            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
//            let renderComponent = entity.getComponent(componentClass: RenderComponent.self)!
//            let particleComponent = entity.getComponent(componentClass: ParticleComponent.self)!
//
//            let modelMatrix = calculateModelMatrix(transformComponent: transformComponent, viewMatrix: viewMatrix)
//
//            var modelConstants = ModelConstants(modelMatrix: modelMatrix)
//            renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
//
//            updateTextureCoordInfo(renderCommandEncoder: renderCommandEncoder, particleComponent: particleComponent)
//
//            renderComponent.mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
//                                                material: renderComponent.material,
//                                                baseColourTextureType: renderComponent.textureType,
//                                                baseNormalMapTextureType: renderComponent.normalMapType)
//        }
    }
    
//    func updateTextureCoordInfo(renderCommandEncoder: MTLRenderCommandEncoder, particleComponent: ParticleComponent) {
//        let lifeFactor = particleComponent.elapsedTime / particleComponent.lifeLength
//        let stageCount = textureRows * textureRows
//        let atlasProgression = lifeFactor * Float(stageCount)
//        let index1 = Int(floor(atlasProgression))
//        let index2 = index1 < stageCount - 1 ? index1 + 1 : index1
//
//        let offset1 = setTextureOffset(index: index1)
//        let offset2 = setTextureOffset(index: index2)
//
//        var offset = SIMD4<Float>(offset1.x, offset1.y, offset2.x, offset2.y)
//        var numberOfRows = Float(textureRows)
//        var blendFactor = atlasProgression.truncatingRemainder(dividingBy: 1)
//
//        renderCommandEncoder.setVertexBytes(&offset, length: SIMD4<Float>.size, index: 3)
//        renderCommandEncoder.setVertexBytes(&numberOfRows, length: Float.size, index: 4)
//        renderCommandEncoder.setVertexBytes(&blendFactor, length: SIMD2<Float>.size, index: 5)
//    }
//
//    func setTextureOffset(index: Int) -> SIMD2<Float> {
//        let column = index % textureRows
//        let row = index / textureRows
//        return SIMD2<Float>(Float(column) / Float(textureRows), Float(row) / Float(textureRows))
//    }
//
//    private func calculateModelMatrix(transformComponent: TransformComponent, viewMatrix: simd_float4x4) -> simd_float4x4 {
//        var modelMatrix = matrix_identity_float4x4
//        modelMatrix.translate(direction: transformComponent.position)
//
//        var result = matrix_identity_float4x4
//        result.columns = (
//            SIMD4<Float>(viewMatrix.columns.0.x, modelMatrix.columns.1.x, viewMatrix.columns.2.x, 0.0),
//            SIMD4<Float>(viewMatrix.columns.0.y, modelMatrix.columns.1.y, viewMatrix.columns.2.y, 0.0),
//            SIMD4<Float>(viewMatrix.columns.0.z, modelMatrix.columns.1.z, viewMatrix.columns.2.z, 0.0),
//            SIMD4<Float>(0.0,  0.0,  0.0,  1.0)
//        )
//        modelMatrix = matrix_multiply(modelMatrix, result)
//
//        modelMatrix.rotate(angle: transformComponent.rotation.z, axis: Z_AXIS)
//        modelMatrix.scale(axis: transformComponent.scale)
//
//        return modelMatrix
//    }
    
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
    
//    private func insertionSort(list: inout [Entity]) {
//        if list.count == 0 || list.count == 1 { return }
//        
//        for j in 1..<list.count {
//            let keyElement = list[j]
//            let key = keyElement.getComponent(componentClass: ParticleComponent.self)!.distance
//
//            var i = j - 1
//
//            while i >= 0 && list[i].getComponent(componentClass: ParticleComponent.self)!.distance < key {
//                list[i + 1] = list[i]
//                i = i - 1
//            }
//
//            list[i + 1] = keyElement
//        }
//    }
}
