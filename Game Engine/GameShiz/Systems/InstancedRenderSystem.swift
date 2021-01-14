import MetalKit

class InstancedRenderSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: InstancedTransformComponent.self, RenderComponent.self)
    
    var entityBuffers = Dictionary<Entity, MTLBuffer>()
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        let cameras = engine.getEntities(for: Family.all(components: CameraComponent.self))
        let camera = cameras[0]
        let cameraComp = camera.getComponent(componentClass: CameraComponent.self)!
        
        for entity in entities {
            guard let boundingBoxComp = entity.getComponent(componentClass: BoundingBoxComponent.self) else { continue }
            let instancedTransformComp = entity.getComponent(componentClass: InstancedTransformComponent.self)!
            
            var count = 0
            
            for transformComp in instancedTransformComp.transformComponents {
                let relativeScale = boundingBoxComp.size * transformComp.scale
                let origin = boundingBoxComp.position + transformComp.position
                
                let radius = length(relativeScale / 2)
                
                transformComp.isInFrustum = cameraComp.frustum.sphereIntersection(center: origin, radius: radius)
                
                count += 1
                
//                print(transformComp.isInFrustum)
            }
            
            let modelConstantsBuffer = Engine.device.makeBuffer(length: ModelConstants.stride(count), options: [])
            entityBuffers[entity] = modelConstantsBuffer
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        // TODO: Get me from a transform component
        let modelMatrix = matrix_identity_float4x4
        
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Instanced])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        for entity in entities {
            let instancedTransformComponent = entity.getComponent(componentClass: InstancedTransformComponent.self)!
                        
            if let modelConstantsBuffer = entityBuffers[entity] {
                var transformComponents: [TransformComponent] = []
                var instanceCount: Int = 0
                
                for transformComponent in instancedTransformComponent.transformComponents {
                    if !transformComponent.isInFrustum { continue }
                    
                    transformComponents.append(transformComponent)
                    instanceCount += 1
                }
                
                if instanceCount == 0 { continue }
                
                var pointer = modelConstantsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: instanceCount)
                
                for transformComponent in transformComponents {
                    pointer.pointee.modelMatrix = matrix_multiply(modelMatrix, transformComponent.modelMatrix)
                    pointer = pointer.advanced(by: 1)
                }
                
                let renderComponent = entity.getComponent(componentClass: RenderComponent.self)!
                
                let mesh = renderComponent.mesh
                mesh.setInstanceCount(instanceCount)
                
                renderCommandEncoder.setVertexBuffer(modelConstantsBuffer, offset: 0, index: 2)
                mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
                                    material: renderComponent.material,
                                    baseColourTextureType: renderComponent.textureType,
                                    baseNormalMapTextureType: renderComponent.normalMapType)
            }
        }
    }
    
//    edTech
//    qDoctor
//    
    
    func onEntityAdded(entity: Entity) {
        if family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
            
            guard let instancedTransformComponent = entity.getComponent(componentClass: InstancedTransformComponent.self) else { return }
            let modelConstantsBuffer = Engine.device.makeBuffer(length: ModelConstants.stride(instancedTransformComponent.instanceCount), options: [])
            entityBuffers[entity] = modelConstantsBuffer
        }
    }
    
    func onEntityRemoved(entity: Entity) {
        if !family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
            
            entityBuffers.removeValue(forKey: entity)
        }
    }
    
    func onAddedToEngine(engine: ECS) {
        self.entities = engine.getEntities(for: family)
        self.engine = engine
        
        for entity in entities {
            guard let instancedTransformComponent = entity.getComponent(componentClass: InstancedTransformComponent.self) else { continue }
            let modelConstantsBuffer = Engine.device.makeBuffer(length: ModelConstants.stride(instancedTransformComponent.instanceCount), options: [])
            entityBuffers[entity] = modelConstantsBuffer
        }
    }
}
