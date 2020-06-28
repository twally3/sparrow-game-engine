import MetalKit

struct EndPoint {
    public var isMin: Bool
    public var box: Entity
    public var boxId: Int
    
    public var value: SIMD3<Float> {
        let entity = self.box
        let boundingBoxComponent = entity.getComponent(componentClass: BoundingBoxComponent.self)!
        let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
        
        let relativeScale = boundingBoxComponent.size * transformComponent.scale
        let origin = boundingBoxComponent.position + transformComponent.position
        
        return self.isMin ? origin - relativeScale / 2 : origin + relativeScale / 2
    }
}

struct Box {
    public var id: Int
    public var min: EndPoint
    public var max: EndPoint
}

enum Axis {
    case x
    case y
    case z
}

/*
 REFERENCES
 https://github.com/mattleibow/jitterphysics/wiki/Sweep-and-Prune
 http://www.codercorner.com/SAP.pdf
 */
class CollisionSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: TransformComponent.self, BoundingBoxComponent.self)
    
    var boxes = ContiguousArray<Box>()
    
    // TODO: Reset me when the list changes
    var pairs = Array<(Entity, Entity)>()
    var endPointsX = ContiguousArray<EndPoint>()
    var endPointsY = ContiguousArray<EndPoint>()
    var endPointsZ = ContiguousArray<EndPoint>()
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        sortAxis(endPoints: &endPointsX, axis: .x)
        sortAxis(endPoints: &endPointsY, axis: .y)
        sortAxis(endPoints: &endPointsZ, axis: .z)
    }
    
    func sortAxis(endPoints: inout ContiguousArray<EndPoint>, axis: Axis) {
        for j in 1..<endPoints.count {
            let keyElement = endPoints[j]
            // TODO: Calculate Axis variance and use dynamically
            let key = getAxisValue(point: keyElement.value, axis: axis)

            
            var i = j - 1
            
            while i >= 0 && getAxisValue(point: endPoints[i].value, axis: axis) > key {
                let swapper = endPoints[i]
                
                if keyElement.isMin && !swapper.isMin {
                    if intersectsBox(a: boxes[keyElement.boxId], b: boxes[swapper.boxId]) {
                        pairs.append((swapper.box, keyElement.box))
                    }
                }
                
                if !keyElement.isMin && swapper.isMin {
                    pairs.removeAll { (pair) -> Bool in
                        let a = pair.0
                        let b = pair.1
                        return keyElement.box == a && swapper.box == b || swapper.box == a && keyElement.box == b
                    }
                }
                
                endPoints[i + 1] = swapper
                i = i - 1
            }
            
            endPoints[i + 1] = keyElement
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(Graphics.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(Graphics.depthStencilStates[.Less])
        
        for entity in entities {
            let transformComponent = entity.getComponent(componentClass: TransformComponent.self)!
            let boundingBoxComponent = entity.getComponent(componentClass: BoundingBoxComponent.self)!
            
            let material = Material(colour: SIMD4<Float>(0, 1, 0, 1),
                                    isLit: true,
                                    ambient: SIMD3<Float>(repeating: 0.1),
                                    diffuse: SIMD3<Float>(repeating: 1),
                                    specular: SIMD3<Float>(repeating: 1),
                                    shininess: 2)
            
            let mesh = Entities.meshes[.Cube_Custom]
            
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.translate(direction: transformComponent.position + boundingBoxComponent.position)
            modelMatrix.scale(axis: boundingBoxComponent.size * transformComponent.scale * 1.001)
            
            var modelConstants = ModelConstants(modelMatrix: modelMatrix)
            renderCommandEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
            renderCommandEncoder.setTriangleFillMode(.lines)
            mesh.drawPrimitives(renderCommandEncoder: renderCommandEncoder,
                                material: material)
        }
    }
    
    func onEntityAdded(entity: Entity) {
        if family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
            setList()
        }
    }
    
    func onEntityRemoved(entity: Entity) {
        if !family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
            setList()
        }
    }
    
    func onAddedToEngine(engine: ECS) {
        self.entities = engine.getEntities(for: family)
        self.engine = engine
        
        setList()
    }
    
    private func intersectsBox(a: Box, b: Box) -> Bool {
        return a.min.value.x <= b.max.value.x && a.max.value.x >= b.min.value.x &&
            a.min.value.y <= b.max.value.y && a.max.value.y >= b.min.value.y &&
            a.min.value.z <= b.max.value.z && a.max.value.z >= b.min.value.z
    }
    
    private func getAxisValue(point: SIMD3<Float>, axis: Axis) -> Float {
        switch axis {
        case .x:
            return point.x
        case .y:
            return point.y
        case .z:
            return point.z
        }
    }
    
    // TODO: Remove this, calling this on each change is dumb!
    private func setList() {
        var endPoints = ContiguousArray<EndPoint>()
        var boxes = ContiguousArray<Box>()
        
        for (i, entity) in entities.enumerated() {
            let minPoint = EndPoint(isMin: true,
                                    box: entity,
                                    boxId: i)
            
            let maxPoint = EndPoint(isMin: false,
                                    box: entity,
                                    boxId: i)
            
            let box = Box(id: i, min: minPoint, max: maxPoint)
            
            endPoints.append(minPoint)
            endPoints.append(maxPoint)
            boxes.append(box)
        }
        
        self.endPointsX = endPoints
        self.endPointsY = endPoints
        self.endPointsZ = endPoints
        self.boxes = boxes
    }
}
