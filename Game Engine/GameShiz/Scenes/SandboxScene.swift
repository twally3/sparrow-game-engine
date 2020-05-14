class SandboxScene: Scene {
    
    override func buildScene() {
//        camera.setPosition(0, 0, 3)
//        addCamera(camera)
        
        do {
            let cube = engine.createEntity()
            try cube.add(component: TransformComponent(position: SIMD3<Float>(-2, 0, 0)))
            try cube.add(component: RenderComponent(isLit: false,
                                                    colour: SIMD4<Float>(1, 1, 0, 1),
                                                    mesh: Entities.meshes[.Cube_Custom]))

            try engine.addEntity(entity: cube)

            let cube2 = engine.createEntity()
            try cube2.add(component: RotatableComponent(axis: SIMD3<Float>(0, 1, 0)))
            try cube2.add(component: TransformComponent(position: SIMD3<Float>(2, 0, 0)))
            try cube2.add(component: RenderComponent(isLit: false,
                                                    colour: SIMD4<Float>(1, 0, 1, 1),
                                                    mesh: Entities.meshes[.Cube_Custom]))

            try engine.addEntity(entity: cube2)

            let chest = engine.createEntity()
//            try chest.add(component: RotatableComponent(axis: SIMD3<Float>(1, 1, 0)))
            try chest.add(component: TransformComponent(scale: SIMD3<Float>(repeating: 0.01)))
            try chest.add(component: RenderComponent(isLit: true,
                                                     colour: SIMD4<Float>(1, 1, 1, 0),
                                                     mesh: Entities.meshes[.Chest]))
            try engine.addEntity(entity: chest)
            
            let instancedCube = engine.createEntity()
            try instancedCube.add(component: RenderComponent(isLit: true, colour: SIMD4<Float>(1, 0, 0, 1), mesh: Entities.meshes[.Cube_Custom]))
            var transformComponents: [TransformComponent] = []
            let instanceCount = 1000
            for _ in 0..<instanceCount {
                transformComponents.append(TransformComponent(position: SIMD3<Float>.random(in: -50...50),
                                                              scale: SIMD3<Float>(repeating: 1)))
            }
            try instancedCube.add(component: InstancedTransformComponent(instanceCount: instanceCount, transformComponents: transformComponents))
            try engine.addEntity(entity: instancedCube)
            
            let sun = engine.createEntity()
            try sun.add(component: TransformComponent(position: SIMD3<Float>(0, 5, 5), scale: SIMD3<Float>(repeating: 0.3)))
            try sun.add(component: LightComponent())
            try sun.add(component: RenderComponent(isLit: false, colour: SIMD4<Float>(1, 1, 1, 1), mesh: Entities.meshes[.Sphere]))
            
            try engine.addEntity(entity: sun)
            
            let camera = engine.createEntity()
            try camera.add(component: TransformComponent(position: SIMD3<Float>(0, 0, 3)))
            try camera.add(component: CameraComponent())
            try camera.add(component: MouseInputComponent())
            try camera.add(component: KeyboardInputComponent())
            try engine.addEntity(entity: camera)
            
        } catch let error {
            fatalError("\(error)")
        }
    }
}
