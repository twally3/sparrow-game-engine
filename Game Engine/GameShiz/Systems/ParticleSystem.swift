import MetalKit

class ParticleSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    var time: Float = 0
    
    // TODO: Remove particle system ref as requirement
    let family = Family.all(components: TransformComponent.self, ParticleComponent.self, ParticleSystemRefComponent.self, RenderComponent.self)
    
    var systemDict: [ParticleSystemRefComponent? : [Entity]] = [:]
    
//    let pps: Float = 5
//    let averageSpeed: Float = 0.5 //25
//    let averageLifeLength: Float = 0.5
//    let averageScale: Float = 10
//
//    let speedError: Float = 0
//    let lifeError: Float = 0
//    let scaleError: Float = 0
//
//    let direction: SIMD3<Float>? = nil//SIMD3<Float>(0, 1, 0)
//    let directionDeviation: Float = 0//0.1
//
//    let randomRotation: Bool = true
//
//    let textureRows: Int = 8
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        // TODO: Move me so I dont get fetched each time
        let cameras = engine.getEntities(for: Family.all(components: CameraComponent.self))
        let camera = cameras[0]
        let cameraTransformComponent = camera.getComponent(componentClass: TransformComponent.self)!
        let cameraPosition = cameraTransformComponent.position

        for entity in entities {
            let particleComponent = entity.getComponent(componentClass: ParticleComponent.self)!
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!

            particleComponent.velocity.y += -1 * particleComponent.gravityEffect * deltaTime * 0
            let change = SIMD3<Float>(particleComponent.velocity) * deltaTime
            transformComponent.position += change
            particleComponent.elapsedTime += deltaTime
            particleComponent.distance = length_squared(cameraPosition - transformComponent.position)

            if particleComponent.elapsedTime >= particleComponent.lifeLength {
                try! engine.removeEntity(entity: entity)
            }
        }
        
        var dict: [ParticleSystemRefComponent? : [Entity]] = [:]
        var arr = [Entity]()
        
        for entity in entities {
            if let particleSystemRefComponent = entity.getComponent(componentClass: ParticleSystemRefComponent.self) {
                if let arr = dict[particleSystemRefComponent] {
                    var newArr = arr
                    newArr.append(entity)
                    dict[particleSystemRefComponent] = newArr
                } else {
                    dict[particleSystemRefComponent] = [entity]
                }
            } else {
                arr.append(entity)
            }
        }
        
        dict[nil] = arr
        systemDict = dict

        insertionSort(list: &entities)
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Particle])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Particle])

        // TODO: Move me so I dont get fetched each time
        let cameras = engine.getEntities(for: Family.all(components: CameraComponent.self))
        let camera = cameras[0]
        let cameraComponent = camera.getComponent(componentClass: CameraComponent.self)!
        let viewMatrix = cameraComponent.viewMatrix
        
        for (component, entities) in systemDict {
            if let particleSystemRefComponent = component {
                let particleSystemComponent = particleSystemRefComponent.particleSystemComponent
                let renderComponent = particleSystemRefComponent.renderComponent
                
                for entity in entities {
                    let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
                    let particleComponent = entity.getComponent(componentClass: ParticleComponent.self)!
        
                    let modelMatrix = calculateModelMatrix(transformComponent: transformComponent, viewMatrix: viewMatrix)
        
                    var modelConstants = ModelConstants(modelMatrix: modelMatrix)
                    renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
        
                    updateTextureCoordInfo(renderCommandEncoder: renderCommandEncoder,
                                           particleComponent: particleComponent,
                                           particleSystemComponent: particleSystemComponent)
        
                    renderComponent.mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
                                                        material: renderComponent.material,
                                                        baseColourTextureType: renderComponent.textureType,
                                                        baseNormalMapTextureType: renderComponent.normalMapType)
                }
            }
        }
    }
    
//    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
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
//            let particleComponent = entity.getComponent(componentClass: ParticleComponent.self)!
//            let particleSystemRefComponent = entity.getComponent(componentClass: ParticleSystemRefComponent.self)!
//
//            let particleSystemComponent = particleSystemRefComponent.particleSystemComponent
//            let renderComponent = particleSystemRefComponent.renderComponent
//
//            let modelMatrix = calculateModelMatrix(transformComponent: transformComponent, viewMatrix: viewMatrix)
//
//            var modelConstants = ModelConstants(modelMatrix: modelMatrix)
//            renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
//
//            updateTextureCoordInfo(renderCommandEncoder: renderCommandEncoder,
//                                   particleComponent: particleComponent,
//                                   particleSystemComponent: particleSystemComponent)
//
//            renderComponent.mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
//                                                material: renderComponent.material,
//                                                baseColourTextureType: renderComponent.textureType,
//                                                baseNormalMapTextureType: renderComponent.normalMapType)
//        }
//    }
    
    func updateTextureCoordInfo(renderCommandEncoder: MTLRenderCommandEncoder, particleComponent: ParticleComponent, particleSystemComponent: ParticleSystemComponent) {
        let textureRows = particleSystemComponent.textureRows
        
        let lifeFactor = particleComponent.elapsedTime / particleComponent.lifeLength
        let stageCount = textureRows * textureRows
        let atlasProgression = lifeFactor * Float(stageCount)
        let index1 = Int(floor(atlasProgression))
        let index2 = index1 < stageCount - 1 ? index1 + 1 : index1
        
        let offset1 = setTextureOffset(index: index1, textureRows: textureRows)
        let offset2 = setTextureOffset(index: index2, textureRows: textureRows)
        
        var offset = SIMD4<Float>(offset1.x, offset1.y, offset2.x, offset2.y)
        var numberOfRows = Float(textureRows)
        var blendFactor = atlasProgression.truncatingRemainder(dividingBy: 1)

        renderCommandEncoder.setVertexBytes(&offset, length: SIMD4<Float>.size, index: 3)
        renderCommandEncoder.setVertexBytes(&numberOfRows, length: Float.size, index: 4)
        renderCommandEncoder.setVertexBytes(&blendFactor, length: SIMD2<Float>.size, index: 5)
    }
    
    func setTextureOffset(index: Int, textureRows: Int) -> SIMD2<Float> {
        let column = index % textureRows
        let row = index / textureRows
        return SIMD2<Float>(Float(column) / Float(textureRows), Float(row) / Float(textureRows))
    }
    
    private func calculateModelMatrix(transformComponent: TransformComponent, viewMatrix: simd_float4x4) -> simd_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(direction: transformComponent.position)
        
        var result = matrix_identity_float4x4
        result.columns = (
            SIMD4<Float>(viewMatrix.columns.0.x, modelMatrix.columns.1.x, viewMatrix.columns.2.x, 0.0),
            SIMD4<Float>(viewMatrix.columns.0.y, modelMatrix.columns.1.y, viewMatrix.columns.2.y, 0.0),
            SIMD4<Float>(viewMatrix.columns.0.z, modelMatrix.columns.1.z, viewMatrix.columns.2.z, 0.0),
            SIMD4<Float>(0.0,  0.0,  0.0,  1.0)
        )
        modelMatrix = matrix_multiply(modelMatrix, result)
        
        modelMatrix.rotate(angle: transformComponent.rotation.z, axis: Z_AXIS)
        modelMatrix.scale(axis: transformComponent.scale)
        
        return modelMatrix
    }
    
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
    
    private func insertionSort(list: inout [Entity]) {
        if list.count == 0 || list.count == 1 { return }
        
        for j in 1..<list.count {
            let keyElement = list[j]
            let key = keyElement.getComponent(componentClass: ParticleComponent.self)!.distance

            var i = j - 1

            while i >= 0 && list[i].getComponent(componentClass: ParticleComponent.self)!.distance < key {
                list[i + 1] = list[i]
                i = i - 1
            }

            list[i + 1] = keyElement
        }
    }
}
