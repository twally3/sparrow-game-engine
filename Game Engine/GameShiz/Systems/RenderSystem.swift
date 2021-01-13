import MetalKit

class RenderSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, RenderComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        let cameras = engine.getEntities(for: Family.all(components: CameraComponent.self))
        let camera = cameras[0]
        let cameraComp = camera.getComponent(componentClass: CameraComponent.self)!
        
        for entity in entities {
            guard let boundingBoxComp = entity.getComponent(componentClass: BoundingBoxComponent.self) else { continue }
            let transformComp = entity.getComponent(componentClass: TransformComponent.self)!
            
            let relativeScale = boundingBoxComp.size * transformComp.scale
            let origin = boundingBoxComp.position + transformComp.position
            
            let radius = length(relativeScale / 2)
            
            transformComp.isInFrustum = cameraComp.frustum.sphereIntersection(center: origin, radius: radius)
            
//            print(transformComp.isInFrustum)
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        for entity in entities {
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
            let renderComponent = entity.getComponent(componentClass: RenderComponent.self)!
            
            if !transformComponent.isInFrustum { continue }
            
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
