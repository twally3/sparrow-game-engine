import MetalKit

class GuiSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: GuiComponent.self)
    
    let viewConstraintEngine = Renderer.engine
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        self.viewConstraintEngine.update()
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Gui])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Gui])
                
        for entity in entities {
            let guiComponent: GuiComponent = entity.getComponent()!
            
            let viewFrame = guiComponent.view.frame
            let windowFrame = SIMD2<Float>(viewConstraintEngine.window.frame.width.value(),
                                           viewConstraintEngine.window.frame.height.value())
            

            let windowY = viewFrame.minY.value()
            let windowX = viewFrame.minX.value()
            let windowHeight = viewFrame.height.value()
            let windowWidth = viewFrame.width.value()
            
            renderGui(renderCommandEncoder: renderCommandEncoder,
                      position: SIMD3<Float>((windowX / (windowFrame.x / 2)) - 1 + (windowWidth / (windowFrame.x)),
                                             (-windowY / (windowFrame.y / 2)) + (1 - windowHeight / (windowFrame.y)),
                                             0),
                      scale: SIMD3<Float>(windowWidth / windowFrame.x,
                                          windowHeight / windowFrame.y,
                                          0),
                      textureType: guiComponent.textureType)
        }
    }
    
    private func renderGui(renderCommandEncoder: MTLRenderCommandEncoder, position: SIMD3<Float>, scale: SIMD3<Float>, textureType: TextureTypes) {
        let vertices: [SIMD2<Float>] = [
            SIMD2<Float>(-1, 1),
            SIMD2<Float>(-1, -1),
            SIMD2<Float>(1, 1),
            SIMD2<Float>(1, -1)
         ]
        
        let vertexBuffer: MTLBuffer = Engine.device.makeBuffer(bytes: vertices, length: MemoryLayout<SIMD2<Float>>.stride * vertices.count, options: [])!
        var modelMatrix = matrix_identity_float4x4
        
        modelMatrix.translate(direction: position)
        modelMatrix.scale(axis: scale)
        
        var modelConstants = ModelConstants(modelMatrix: modelMatrix)
        renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 1)
        
        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Linear], index: 0)
        renderCommandEncoder.setFragmentTexture(Entities.textures[textureType], index: 0)
        
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
    }
    
    
    func onEntityAdded(entity: Entity) {
        if family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
            
            let view = entity.getComponent(componentClass: GuiComponent.self)!.view
            viewConstraintEngine.add(view: view)
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
