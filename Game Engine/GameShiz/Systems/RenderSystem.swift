import MetalKit

class RenderSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, RenderComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {}
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        for entity in entities {
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
            let renderComponent = entity.getComponent(componentClass: RenderComponent.self)!
            
            // TODO: I shouldnt be here, delete me!
            if let _ = entity.getComponent(componentClass: ParticleComponent.self) { continue }
            
            var modelConstants = ModelConstants(modelMatrix: transformComponent.modelMatrix)
            renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
            
            renderComponent.mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
                                                material: renderComponent.material,
                                                baseColourTextureType: renderComponent.textureType,
                                                baseNormalMapTextureType: renderComponent.normalMapType)
        }
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
}
