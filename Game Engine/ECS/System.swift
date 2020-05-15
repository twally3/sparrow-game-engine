import MetalKit

protocol System {
    var priority: Int { get }
    
    func update(deltaTime: Float)
    func render(renderCommandEncoder: MTLRenderCommandEncoder)
    func onEntityAdded(entity: Entity)
    func onEntityRemoved(entity: Entity)
    func onAddedToEngine(engine: ECS)
}

extension System {
    static var classIdentifier: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}
