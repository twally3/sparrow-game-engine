import MetalKit

class SkyboxSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var cameras: [Entity] = []
    var engine: ECS!
    
    let skyboxFamily = Family.all(components: TransformComponent.self, SkyboxComponent.self)
    let fpsCamraFamilyFamily = Family.all(components: TransformComponent.self, CameraComponent.self, FPSCameraComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        let camera = cameras[0]
        let cameraComponent = camera.getComponent(componentClass: TransformComponent.self) as! TransformComponent
        let cameraPosition = cameraComponent.position
        
        for entity in entities {
            let transform = entity.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            transform.position = cameraPosition
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.SkyBox])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.SkyBox])
        
        for entity in entities {
            let skyboxComponent = entity.getComponent(componentClass: SkyboxComponent.self) as! SkyboxComponent
            let transform = entity.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            
            let mesh = skyboxComponent.mesh
            
            var modelConstants = ModelConstants(modelMatrix: transform.modelMatrix)
            renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
            
            mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder, baseColourTextureType: skyboxComponent.textureType)
        }
    }
    
    func onEntityAdded(entity: Entity) {
        if skyboxFamily.matches(entity: entity) {
            self.entities = engine.getEntities(for: skyboxFamily)
        }
        if fpsCamraFamilyFamily.matches(entity: entity) {
            self.cameras = engine.getEntities(for: fpsCamraFamilyFamily)
        }
    }
    
    func onEntityRemoved(entity: Entity) {
        if !skyboxFamily.matches(entity: entity) {
            self.entities = engine.getEntities(for: skyboxFamily)
        }
        if !fpsCamraFamilyFamily.matches(entity: entity) {
            self.cameras = engine.getEntities(for: fpsCamraFamilyFamily)
        }
    }
    
    func onAddedToEngine(engine: ECS) {
        self.entities = engine.getEntities(for: skyboxFamily)
        self.cameras = engine.getEntities(for: fpsCamraFamilyFamily)
        self.engine = engine
    }
}
