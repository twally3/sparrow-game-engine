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
    
    func update(deltaTime: Float) {}
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        // TODO: Get me from a transform component
        let modelMatrix = matrix_identity_float4x4
        
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Instanced])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        for entity in entities {
            let instancedTransformComponent = entity.getComponent(componentClass: InstancedTransformComponent.self)!
            let instanceCount = instancedTransformComponent.instanceCount
            
            if let modelConstantsBuffer = entityBuffers[entity] {
                var pointer = modelConstantsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: instanceCount)
                
                for transformComponent in instancedTransformComponent.transformComponents {
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
