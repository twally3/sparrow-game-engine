import simd

class DebugScene: Scene {
    
    override func buildScene() {
        do {
            let skybox = engine.createEntity()
            try skybox.add(component: TransformComponent(scale: SIMD3<Float>(repeating: 1000)))
            try skybox.add(component: SkyboxComponent(textureType: .SkyBox))
            try engine.addEntity(entity: skybox)
            
            let sun = engine.createEntity()
            
            var sunMaterial = Material()
            sunMaterial.colour = SIMD4<Float>(0.7, 0.5, 0, 1)
            sunMaterial.isLit = false
            
            try sun.add(component: RenderComponent(mesh: Entities.meshes[.Sphere],
                                                   textureType: .None,
                                                   normalMapType: .None,
                                                   material: sunMaterial))
            try sun.add(component: TransformComponent(position: SIMD3<Float>(0, 100, 100),
                                                      rotation: SIMD3<Float>(0, 0, 0),
                                                      scale: SIMD3<Float>(10, 10, 10)))
            try sun.add(component: LightComponent())
            try engine.addEntity(entity: sun)
            
            let terrain = engine.createEntity()
            try terrain.add(component: TransformComponent(position: SIMD3<Float>(repeating: 0),
                                                      rotation: SIMD3<Float>(repeating: 0),
                                                      scale: SIMD3<Float>(repeating: 200)))
            try terrain.add(component: RenderComponent(mesh: Entities.meshes[.GroundGrass]))
            try engine.addEntity(entity: terrain)
            
            let tent = engine.createEntity()
            try tent.add(component: TransformComponent(position: SIMD3<Float>(repeating: 0),
                                                       rotation: SIMD3<Float>(0, 0, 0),
                                                       scale: SIMD3<Float>(repeating: 1)))
            try tent.add(component: RenderComponent(mesh: Entities.meshes[.Tent_Opened]))
            try tent.add(component: BoundingBoxComponent.fromBounds(min: Entities.meshes[.Tent_Opened].minBound,
                                                                    max: Entities.meshes[.Tent_Opened].maxBound))
            try engine.addEntity(entity: tent)
            
            let treeAs = engine.createEntity()
            try treeAs.add(component: RenderComponent(mesh: Entities.meshes[.TreePineA]))
            let count = 100
            try treeAs.add(component: InstancedTransformComponent(instanceCount: count, transformComponents: getTreeTransformComponents(count: count)))
//            try treeAs.add(component: BoundingBoxComponent.fromBounds(min: Entities.meshes[.TreePineA].minBound,
//                                                                      max: Entities.meshes[.TreePineA].maxBound))
            try engine.addEntity(entity: treeAs)

            
            let camera = engine.createEntity()
            try camera.add(component: TransformComponent(position: SIMD3<Float>(0, 1, 3)))
            try camera.add(component: CameraComponent())
            try camera.add(component: MouseInputComponent())
            try camera.add(component: KeyboardInputComponent())
            try camera.add(component: FPSCameraComponent())
            try engine.addEntity(entity: camera)
            
        } catch let error {
            fatalError("\(error)")
        }
    }
    
    private func getTreeTransformComponents(count: Int) -> [TransformComponent] {
        var transformComponents = [TransformComponent]()
        
        for i in 0..<count {
            let radius: Float = 70 //Float.random(in: 8...70)
            let pos = SIMD3<Float>(cos(Float(i)) * radius, 0, sin(Float(i)) * radius)
//            let rot = SIMD3<Float>(0, Float.random(in: 0...360), 0)
            let rot = SIMD3<Float>(0, 0, 0)
//            let scale = SIMD3<Float>(repeating: Float.random(in: 1...2))
            let scale = SIMD3<Float>(repeating: 1)
            
            transformComponents.append(TransformComponent(position: pos,
                                                          rotation: rot,
                                                          scale: scale))
        }
        
        return transformComponents
     }
}
