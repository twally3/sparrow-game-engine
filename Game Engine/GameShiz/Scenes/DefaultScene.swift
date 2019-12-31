import GameplayKit

class DefaultScene: Scene {
    let camera = DebugCamera()
    let sun = Sun()
    let plane = Plane()
    
    let mapWidth: Int = 100
    let mapHeight: Int = 100
    let noiseScale: Float = 9
    
    override func buildScene() {
        camera.setPosition(0, 0, 4)
        addCamera(camera)
        
        sun.setPosition(0, 3, 0)
        addLight(sun)
        
        addPlane()
    }
    
    func addPlane() {
        let noiseMap = generateRandomTexture()
        
        let mapValuesBuffer = Engine.device!.makeBuffer(bytes: noiseMap, length: MemoryLayout<Float>.size * noiseMap.count, options: [])
        
        let texture = loadEmptyTexture()
        
        let computePipelineState = createComputePipelineState()
        
        loadTextureWithHeights(computePipelineState: computePipelineState, mapValuesBuffer: mapValuesBuffer!, texture: texture)
        
        plane.setMaterialIsLit(false)
        plane.setTexture(texture)
        addChild(plane)
    }
    
    func generateRandomTexture() -> [Float] {
        let noise = Noise.generateNoiseMap(mapWidth: mapWidth, mapHeight: mapHeight, scale: noiseScale)
        
        var mapValues: [Float] = []
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                mapValues.append(noise[x][y])
            }
        }
        
        return mapValues
    }
    
    public func loadEmptyTexture()->MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = mapWidth
        textureDescriptor.height = mapHeight
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.sampleCount = 1
        textureDescriptor.storageMode = .managed
        textureDescriptor.usage = [.shaderWrite, .shaderRead]
        
        let texture = Engine.device!.makeTexture(descriptor: textureDescriptor)
        return texture!
    }
    
    func createComputePipelineState() -> MTLComputePipelineState {
        do {
            return try Engine.device!.makeComputePipelineState(function: Graphics.shaders[.CreateHeightMap_Compute])
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func loadTextureWithHeights(computePipelineState: MTLComputePipelineState, mapValuesBuffer: MTLBuffer, texture: MTLTexture) {
        let commandQueue = Engine.commandQueue
        let commandBuffer = commandQueue!.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeCommandEncoder?.setComputePipelineState(computePipelineState)
        
        computeCommandEncoder?.setTexture(texture, index: 0)
        computeCommandEncoder?.setBuffer(mapValuesBuffer, offset: 0, index: 0)
        
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadgroupsPerGrid = MTLSize(width: (texture.width + w - 1) / w,
                                          height: (texture.height + h - 1) / h,
                                          depth: 1)
        
        computeCommandEncoder!.dispatchThreadgroups(threadgroupsPerGrid,
                                                   threadsPerThreadgroup: threadsPerThreadgroup)
        computeCommandEncoder?.endEncoding()
        commandBuffer?.commit()
    }
    
    override func doUpdate() {
        if (Mouse.isMouseButtonPressed(button: .LEFT)) {
            plane.rotateX(Mouse.getDY() * GameTime.deltaTime)
            plane.rotateY(Mouse.getDX() * GameTime.deltaTime)
        }
    }
}
