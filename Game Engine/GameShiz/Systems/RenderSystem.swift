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
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            let renderComponent = entity.getComponent(componentClass: RenderComponent.self) as! RenderComponent
            
            var material = Material()
            material.isLit = renderComponent.isLit
            material.colour = renderComponent.colour
            
            let mesh = renderComponent.mesh
            
            var modelConstants = ModelConstants(modelMatrix: transformComponent.modelMatrix)
            renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
            
            renderCommandEncoder.setFrontFacing(.counterClockwise)
            
            mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
                                material: material,
                                baseColourTextureType: .None)
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
