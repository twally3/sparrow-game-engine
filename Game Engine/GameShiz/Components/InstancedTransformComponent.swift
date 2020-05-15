class InstancedTransformComponent: Component {
    var transformComponents: [TransformComponent]
    var instanceCount: Int
    
    init(instanceCount: Int, transformComponents: [TransformComponent]) {
        self.instanceCount = instanceCount
        self.transformComponents = transformComponents
    }
}
