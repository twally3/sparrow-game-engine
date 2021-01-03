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
            
//            let windowY = viewFrame.minY.value()
//            let windowY: Float = 360
//            let windowY: Float = 0
//            let windowY: Float = 180
            
//            let windowHeight: Float = 720
//            let windowHeight: Float = 360
//            let windowHeight: Float = 180
//            let windowHeight: Float = 0
            
//            let windowX = viewFrame.minX.value()
//            let windowX: Float = 540
//            let windowWidth = viewFrame.width.value()
//            let windowWidth: Float = 1080
//            let windowWidth: Float = 540
//            let windowWidth: Float = 270

            let windowY = viewFrame.minY.value()
            let windowX = viewFrame.minX.value()
            let windowHeight = viewFrame.height.value()
            let windowWidth = viewFrame.width.value()
            
            renderGui(renderCommandEncoder: renderCommandEncoder,
                      position: SIMD3<Float>((windowX / (windowFrame.x / 2)) - 1 + (windowWidth / (windowFrame.x)), //(1 - windowWidth / (windowFrame.x)),
//                                             (-windowY / (windowFrame.y / 2)) + 0.5,
                                             (-windowY / (windowFrame.y / 2)) + (1 - windowHeight / (windowFrame.y)),
                                             0),
                      scale: SIMD3<Float>(windowWidth / windowFrame.x,
                                          windowHeight / windowFrame.y,
                                          0),
                      textureType: guiComponent.textureType)
            
//            renderGui(renderCommandEncoder: renderCommandEncoder,
//                      position: SIMD3<Float>(viewFrame.minX.value(),
//                                             viewFrame.minY.value(),
//                                             0),
//                      scale: SIMD3<Float>(viewFrame.width.value(),
//                                          viewFrame.height.value(),
//                                          0),
//                      textureType: guiComponent.textureType)
            
        }
    }
    
    private func renderGui(renderCommandEncoder: MTLRenderCommandEncoder, position: SIMD3<Float>, scale: SIMD3<Float>, textureType: TextureTypes) {
        let vertices: [SIMD2<Float>] = [
            SIMD2<Float>(-1, 1),
            SIMD2<Float>(-1, -1),
            SIMD2<Float>(1, 1),
            SIMD2<Float>(1, -1)
         ]
        
        var frame = SIMD2<Float>(viewConstraintEngine.window.frame.width.value(), viewConstraintEngine.window.frame.height.value())
//        var imgSize = SIMD2<Float>(scale.x, scale.y)
//        let scl = SIMD3<Float>(frame.x, -frame.y, 0)
//        let pos = SIMD3<Float>(position.x, -position.y, 0) - (scl / 2)
//
//        let vertices: [SIMD2<Float>] = [
//            SIMD2<Float>(pos.x, pos.y),
//            SIMD2<Float>(pos.x, pos.y - scale.y),
//            SIMD2<Float>(pos.x + scale.x, pos.y),
//            SIMD2<Float>(pos.x + scale.x, pos.y - scale.y),
//        ]

        let vertexBuffer: MTLBuffer = Engine.device.makeBuffer(bytes: vertices, length: MemoryLayout<SIMD2<Float>>.stride * vertices.count, options: [])!
        var modelMatrix = matrix_identity_float4x4
        
//        modelMatrix.translate(direction: SIMD3<Float>(position.x / (frame.x), -position.y / (frame.y), 0))
//        modelMatrix.scale(axis: SIMD3<Float>(scale.x / frame.x, scale.y / frame.y, 0))
        modelMatrix.translate(direction: position)
        modelMatrix.scale(axis: scale)
        
        var modelConstants = ModelConstants(modelMatrix: modelMatrix)
        renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 1)
//        renderCommandEncoder.setVertexBytes(&frame, length: SIMD2<Float>.stride, index: 2)
//        renderCommandEncoder.setVertexBytes(&imgSize, length: SIMD2<Float>.stride, index: 3)
        
        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Linear], index: 0)
        renderCommandEncoder.setFragmentTexture(Entities.textures[textureType], index: 0)
        
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
    }
    
//    private func renderGui(renderCommandEncoder: MTLRenderCommandEncoder, position: SIMD3<Float>, scale: SIMD3<Float>, textureType: TextureTypes) {
////        let vertices: [SIMD2<Float>] = [
////            SIMD2<Float>(-1, 1),
////            SIMD2<Float>(-1, -1),
////            SIMD2<Float>(1, 1),
////            SIMD2<Float>(1, -1)
////         ]
//        
//        var frame = SIMD2<Float>(viewConstraintEngine.window.frame.width.value(), viewConstraintEngine.window.frame.height.value())
//        var imgSize = SIMD2<Float>(scale.x, scale.y)
//        let scl = SIMD3<Float>(frame.x, -frame.y, 0)
//        let pos = SIMD3<Float>(position.x, -position.y, 0) - (scl / 2)
//        
//        let vertices: [SIMD2<Float>] = [
//            SIMD2<Float>(pos.x, pos.y),
//            SIMD2<Float>(pos.x, pos.y - scale.y),
//            SIMD2<Float>(pos.x + scale.x, pos.y),
//            SIMD2<Float>(pos.x + scale.x, pos.y - scale.y),
//        ]
//
//        let vertexBuffer: MTLBuffer = Engine.device.makeBuffer(bytes: vertices, length: MemoryLayout<SIMD2<Float>>.stride * vertices.count, options: [])!
//        let modelMatrix = matrix_identity_float4x4
////        modelMatrix.translate(direction: position)
////        modelMatrix.scale(axis: scale)
//        
//        var modelConstants = ModelConstants(modelMatrix: modelMatrix)
//        renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 1)
//        renderCommandEncoder.setVertexBytes(&frame, length: SIMD2<Float>.stride, index: 2)
//        renderCommandEncoder.setVertexBytes(&imgSize, length: SIMD2<Float>.stride, index: 3)
//        
//        renderCommandEncoder.setFragmentSamplerState(Graphics.samplerStates[.Linear], index: 0)
//        renderCommandEncoder.setFragmentTexture(Entities.textures[textureType], index: 0)
//        
//        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
//    }
    
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
