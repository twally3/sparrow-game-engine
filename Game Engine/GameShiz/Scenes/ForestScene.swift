import simd

class ForestScene: Scene {
    
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
                                                       rotation: SIMD3<Float>(0, Float(20).toRadians, 0),
                                                       scale: SIMD3<Float>(repeating: 1)))
            try tent.add(component: RenderComponent(mesh: Entities.meshes[.Tent_Opened]))
            try engine.addEntity(entity: tent)
            
            let redFlowers = engine.createEntity()
            try redFlowers.add(component: RenderComponent(mesh: Entities.meshes[.FlowerRed]))
            try redFlowers.add(component: InstancedTransformComponent(instanceCount: 1000, transformComponents: getFlowerTransformComponents(count: 1000)))
            try engine.addEntity(entity: redFlowers)
            
            let purpleFlowers = engine.createEntity()
            try purpleFlowers.add(component: RenderComponent(mesh: Entities.meshes[.FlowerPurple]))
            try purpleFlowers.add(component: InstancedTransformComponent(instanceCount: 1000, transformComponents: getFlowerTransformComponents(count: 1000)))
            try engine.addEntity(entity: purpleFlowers)
            
            let yellowFlowers = engine.createEntity()
            try yellowFlowers.add(component: RenderComponent(mesh: Entities.meshes[.FlowerYellow]))
            try yellowFlowers.add(component: InstancedTransformComponent(instanceCount: 1000, transformComponents: getFlowerTransformComponents(count: 1000)))
            try engine.addEntity(entity: yellowFlowers)
            
            let treeAs = engine.createEntity()
            try treeAs.add(component: RenderComponent(mesh: Entities.meshes[.TreePineA]))
            try treeAs.add(component: InstancedTransformComponent(instanceCount: 1000, transformComponents: getTreeTransformComponents(count: 1000)))
            try engine.addEntity(entity: treeAs)
            
            let treeBs = engine.createEntity()
            try treeBs.add(component: RenderComponent(mesh: Entities.meshes[.TreePineB]))
            try treeBs.add(component: InstancedTransformComponent(instanceCount: 1000, transformComponents: getTreeTransformComponents(count: 1000)))
            try engine.addEntity(entity: treeBs)
            
            let treeCs = engine.createEntity()
            try treeCs.add(component: RenderComponent(mesh: Entities.meshes[.TreePineC]))
            try treeCs.add(component: InstancedTransformComponent(instanceCount: 1000, transformComponents: getTreeTransformComponents(count: 1000)))
            try engine.addEntity(entity: treeCs)
            
            let box1 = View()
            let box2 = View()
            let box3 = View()
            
            let box1Entity = engine.createEntity()
            box1.addConstraints([
                box1.topAnchor.constraint(equalTo: Renderer.engine.window.topAnchor),
                box1.leadingAnchor.constraint(equalTo: Renderer.engine.window.leadingAnchor),
                box1.trailingAnchor.constraint(equalTo: Renderer.engine.window.trailingAnchor),
                box1.heightAnchor.constraint(equalTo: Renderer.engine.window.heightAnchor, multiplier: 0.5)
            ])
            try box1Entity.add(component: GuiComponent(view: box1, textureType: .Heart))
            try engine.addEntity(entity: box1Entity)
            
            let box2Entity = engine.createEntity()
            box2.addConstraints([
                box2.topAnchor.constraint(equalTo: box1.bottomAnchor),
                box2.leadingAnchor.constraint(equalTo: Renderer.engine.window.leadingAnchor),
                box2.bottomAnchor.constraint(equalTo: Renderer.engine.window.bottomAnchor),
                box2.widthAnchor.constraint(equalTo: Renderer.engine.window.widthAnchor, multiplier: 0.5)
            ])
            try box2Entity.add(component: GuiComponent(view: box2, textureType: .Heart))
            try engine.addEntity(entity: box2Entity)
            
            let box3Entity = engine.createEntity()
            box3.addConstraints([
                box3.topAnchor.constraint(equalTo: box1.bottomAnchor),
                box3.leadingAnchor.constraint(equalTo: box2.trailingAnchor),
                box3.bottomAnchor.constraint(equalTo: Renderer.engine.window.bottomAnchor),
                box3.trailingAnchor.constraint(equalTo: Renderer.engine.window.trailingAnchor)
            ])
            try box3Entity.add(component: GuiComponent(view: box3, textureType: .Heart))
            try engine.addEntity(entity: box3Entity)
            
            
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
    
    private func getFlowerTransformComponents(count: Int) -> [TransformComponent] {
        var transformComponents = [TransformComponent]()
        
        for i in 0..<count {
            let radius: Float = Float.random(in: 0.9...70)
            let pos = SIMD3<Float>(cos(Float(i)) * radius, 0, sin(Float(i)) * radius)
            
            transformComponents.append(TransformComponent(position: pos,
                                                          rotation: SIMD3<Float>(0, Float.random(in: 0...360), 0),
                                                          scale: SIMD3<Float>(repeating: Float.random(in: 0.6...0.8))))
        }
        
        return transformComponents
    }
    
    private func getTreeTransformComponents(count: Int) -> [TransformComponent] {
        var transformComponents = [TransformComponent]()
        
        for i in 0..<count {
            let radius: Float = Float.random(in: 8...70)
            let pos = SIMD3<Float>(cos(Float(i)) * radius, 0, sin(Float(i)) * radius)
            
            transformComponents.append(TransformComponent(position: pos,
                                                          rotation: SIMD3<Float>(0, Float.random(in: 0...360), 0),
                                                          scale: SIMD3<Float>(repeating: Float.random(in: 1...2))))
        }
        
        return transformComponents
     }
}
