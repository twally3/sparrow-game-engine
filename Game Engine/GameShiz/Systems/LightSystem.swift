import MetalKit

class LightSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, LightComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {}
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        var lightDatas: [LightData] = []
        for entity in entities {
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            let lightComponent = entity.getComponent(componentClass: LightComponent.self) as! LightComponent
            
            let lightData = LightData(position: transformComponent.position,
                                      colour: lightComponent.colour,
                                      brightness: lightComponent.brightness,
                                      ambientIntensity: lightComponent.ambientIntensity,
                                      diffuseIntensity: lightComponent.diffuseIntensity,
                                      specularIntensity: lightComponent.specularIntensity)
            
            lightDatas.append(lightData)
        }
        
        var lightCount = lightDatas.count
        renderCommandEncoder.setFragmentBytes(&lightCount, length: Int32.size, index: 2)
        renderCommandEncoder.setFragmentBytes(&lightDatas, length: LightData.stride(lightCount), index: 3)
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
