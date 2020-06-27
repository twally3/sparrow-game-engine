class SandboxScene: Scene {
    
    override func buildScene() {
        do {
            let cube = engine.createEntity()
            try cube.add(component: MovableComponent())
            try cube.add(component: BoundingBoxComponent(position: SIMD3<Float>(0, 0, 0), size: SIMD3<Float>(repeating: 1)))
            try cube.add(component: TransformComponent(position: SIMD3<Float>(-2, 0, 0), scale: SIMD3<Float>(1, 1, 1)))
            try cube.add(component: RenderComponent(mesh: Entities.meshes[.Cube_Custom],
                                                    colour: SIMD4<Float>(1, 1, 0, 1),
                                                    isLit: false))
            try engine.addEntity(entity: cube)

            let cube2 = engine.createEntity()
            try cube2.add(component: BoundingBoxComponent(position: SIMD3<Float>(0, 0, 0), size: SIMD3<Float>(repeating: 1)))
            try cube2.add(component: TransformComponent(position: SIMD3<Float>(1, 0, 0), scale: SIMD3<Float>(repeating: 0.25)))
            try cube2.add(component: RenderComponent(mesh: Entities.meshes[.Cube_Custom],
                                                     colour: SIMD4<Float>(1, 0, 1, 1),
                                                     isLit: false))
            try engine.addEntity(entity: cube2)

//            let chest = engine.createEntity()
//            try chest.add(component: TransformComponent(scale: SIMD3<Float>(repeating: 0.01)))
//            try chest.add(component: RenderComponent(mesh: Entities.meshes[.Chest],
//                                                     colour: SIMD4<Float>(1, 1, 1, 0),
//                                                     isLit: true))
//            try engine.addEntity(entity: chest)
            
//            let instancedCube = engine.createEntity()
//            try instancedCube.add(component: RenderComponent(mesh: Entities.meshes[.Cube_Custom],
//                                                             colour: SIMD4<Float>(1, 0, 0, 1),
//                                                             isLit: true))
//            var transformComponents: [TransformComponent] = []
//            let instanceCount = 1000
//            for _ in 0..<instanceCount {
//                transformComponents.append(TransformComponent(position: SIMD3<Float>.random(in: -50...50),
//                                                              scale: SIMD3<Float>(repeating: 1)))
//            }
//            try instancedCube.add(component: InstancedTransformComponent(instanceCount: instanceCount, transformComponents: transformComponents))
//            try engine.addEntity(entity: instancedCube)
            
            let quad = engine.createEntity()
            try quad.add(component: TransformComponent())
//            try quad.add(component: RenderComponent(mesh: Entities.meshes[.Quad], isLit: true))
            try quad.add(component: RenderComponent(mesh: Entities.meshes[.Quad], textureType: .MetalPlate_Diff, normalMapType: .MetalPlate_Normal, isLit: true))
            try quad.add(component: RotatableComponent(isMouseControlled: true))
            try quad.add(component: MouseInputComponent())
            try engine.addEntity(entity: quad)
            
            let skybox = engine.createEntity()
            try skybox.add(component: TransformComponent(scale: SIMD3<Float>(repeating: 1000)))
            try skybox.add(component: SkyboxComponent(textureType: .SkyBox))
            try engine.addEntity(entity: skybox)
            
            let sun = engine.createEntity()
            try sun.add(component: TransformComponent(position: SIMD3<Float>(0, 5, 5), scale: SIMD3<Float>(repeating: 0.3)))
            try sun.add(component: LightComponent())
            try sun.add(component: RenderComponent(mesh: Entities.meshes[.Sphere],
                                                   colour: SIMD4<Float>(1, 1, 1, 1),
                                                   isLit: false))
            
            try engine.addEntity(entity: sun)
            
            let camera = engine.createEntity()
            try camera.add(component: TransformComponent(position: SIMD3<Float>(0, 0, 3)))
            try camera.add(component: CameraComponent())
            try camera.add(component: MouseInputComponent())
            try camera.add(component: KeyboardInputComponent())
            try camera.add(component: FPSCameraComponent())
            try engine.addEntity(entity: camera)
            
        } catch let error {
            fatalError("\(error)")
        }
    }
}
