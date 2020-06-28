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
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
            let lightComponent = entity.getComponent(componentClass: LightComponent.self)!
            
            let lightData = LightData(position: transformComponent.position,
                                      colour: lightComponent.colour,
                                      brightness: lightComponent.brightness,
                                      ambientIntensity: lightComponent.ambientIntensity,
                                      diffuseIntensity: lightComponent.diffuseIntensity,
                                      specularIntensity: lightComponent.specularIntensity)
            
            lightDatas.append(lightData)
        }
        
        // This is a hack to stop the buffer from exploding with length 0
        if lightDatas.count == 0 {
            lightDatas.append(LightData(position: SIMD3<Float>(0, 0, 0),
                                        colour: SIMD3<Float>(1, 1, 1),
                                        brightness: 0,
                                        ambientIntensity: 0,
                                        diffuseIntensity: 0,
                                        specularIntensity: 0))
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
