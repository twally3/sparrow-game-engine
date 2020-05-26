import MetalKit

struct EndPoint {
    public var value: Float
    public var isMin: Bool
    public var box: Entity
}

struct Box {
    public var min: EndPoint
    public var max: EndPoint
}

class CollisionSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, BoundingBoxComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        var boxes = ContiguousArray<Box>()
        
        for entity in entities {
            let boundingBoxComponent = entity.getComponent(componentClass: BoundingBoxComponent.self) as! BoundingBoxComponent
            let minPoint = EndPoint(value: boundingBoxComponent.position.x, isMin: true, box: entity)
            let maxPoint = EndPoint(value: boundingBoxComponent.position.x + boundingBoxComponent.size.x, isMin: false, box: entity)
                        
            boxes.append(Box(min: minPoint, max: maxPoint))
        }
        
        boxes.sort { (a, b) -> Bool in
            a.min.value < b.min.value
        }
        
        var activeList: [Box] = []
        var pairs = Array<(Box, Box)>()
        
        for i in 0..<boxes.count {
            let box = boxes[i]
            
            for j in 0..<activeList.count {
                let activeBox = activeList[j]
                if box.min.value > activeBox.max.value {
                    activeList.remove(at: j)
                } else {
                    pairs.append((box, activeBox))
//                    print(box, activeBox)
                }
            }
            
            activeList.append(box)
        }
        
        print(pairs)
        print("---")
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        for entity in entities {
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self) as! TransformComponent
            let boundingBoxComponent = entity.getComponent(componentClass: BoundingBoxComponent.self) as! BoundingBoxComponent
            
            let material = Material(colour: SIMD4<Float>(0, 1, 0, 1),
                                    isLit: true,
                                    ambient: SIMD3<Float>(repeating: 0.1),
                                    diffuse: SIMD3<Float>(repeating: 1),
                                    specular: SIMD3<Float>(repeating: 1),
                                    shininess: 2)
            
            let mesh = Entities.meshes[.Cube_Custom]
            
            let modelMatrix = getModelMatrix(position: boundingBoxComponent.position, scale: boundingBoxComponent.size)
            
            var modelConstants = ModelConstants(modelMatrix: modelMatrix)
            renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
            
            mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
                                material: material)
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
    
    func getModelMatrix(position: SIMD3<Float>, scale: SIMD3<Float>) -> matrix_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix.translate(direction: position + 0.5)
        modelMatrix.scale(axis: scale)
        return modelMatrix
    }
}
