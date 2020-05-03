import simd
import Dispatch

class EndlessTerrain {
    var viewer: Node!
    
    var viewerPosition: SIMD2<Float>!
    var viewerPositionOld: SIMD2<Float>!
    var meshWorldSize: Float!
    var chunksVisibleInViewDst: Int!
    
    let viewerMoveThresholdForChunkUpdate: Float = 25;
    
    var terrainChunkDict: [SIMD2<Int> : TerrainChunk] = [:]
    var visibleTerrainChunks: [TerrainChunk] = []
    
    let mapGenerator = MapGenerator()
    
    var maxViewDistance: Float!
    let detailLevels: [LODInfo] = [
        LODInfo(lod: 0, visibleDstThreshold: 400),
        LODInfo(lod: 1, visibleDstThreshold: 500),
        LODInfo(lod: 4, visibleDstThreshold: 600)
    ]
    
    let queue = DispatchQueue(label: "Endless Terrain")
    
    init() {
        self.maxViewDistance = detailLevels.last?.visibleDstThreshold
        self.meshWorldSize = mapGenerator.meshSettings.meshWorldSize
        self.chunksVisibleInViewDst = Int((maxViewDistance / Float(meshWorldSize)).rounded(.toNearestOrEven))
    }
    
    func update() {
        self.viewerPosition = SIMD2<Float>(x: self.viewer.getPositionX(), y: self.viewer.getPositionZ())
        
        if viewerPositionOld == nil || simd_distance(viewerPositionOld, viewerPosition) > viewerMoveThresholdForChunkUpdate {
            viewerPositionOld = viewerPosition;
            updateVisibleChunks();
        }
    }
    
    func updateVisibleChunks() {
        guard let viewerPosition = self.viewerPosition else { return }
        
        var alreadyUpdatedChunkCoords = Set<SIMD2<Int>>()
        
        for i in stride(from: visibleTerrainChunks.count - 1, to: 0, by: -1) {
            alreadyUpdatedChunkCoords.insert(visibleTerrainChunks[i].coord)
            visibleTerrainChunks[i].updateTerrainChunk()
        }
                
        let currentChunkX: Int = Int((viewerPosition.x / Float(meshWorldSize)).rounded(.toNearestOrEven))
        let currentChunkY: Int = Int((viewerPosition.y / Float(meshWorldSize)).rounded(.toNearestOrEven))
        
        for yOffset in stride(from: -chunksVisibleInViewDst, to: chunksVisibleInViewDst, by: 1) {
            for xOffset in stride(from: -chunksVisibleInViewDst, to: chunksVisibleInViewDst, by: 1) {
                let viewedChunkCoord = SIMD2<Int>(x: currentChunkX + xOffset, y: currentChunkY + yOffset)
                
                if !alreadyUpdatedChunkCoords.contains(viewedChunkCoord) {
                    if let terrainChunk = terrainChunkDict[viewedChunkCoord] {
                        terrainChunk.updateTerrainChunk()
                    } else {
                        // Create chunk
                        terrainChunkDict[viewedChunkCoord] = TerrainChunk(parent: self, coord: viewedChunkCoord, meshWorldSize: self.meshWorldSize, detailLevels: detailLevels)
                    }
                }
            }
        }
    }
    
    class TerrainChunk {
        var parent: EndlessTerrain!
        var sampleCentre: SIMD2<Float>!
        var node: Terrain!
        var visibility: Bool = false
        var position: SIMD2<Float>
        
        var detailLevels: [LODInfo]
        var lodMeshes: [LODMesh] = []
        var previousLodIdx: Int = -1
        var mapData: HeightMap!
        
        var coord: SIMD2<Int>
        
        init(parent: EndlessTerrain, coord: SIMD2<Int>, meshWorldSize: Float, detailLevels: [LODInfo]) {
            self.sampleCentre = SIMD2<Float>(coord) * meshWorldSize / parent.mapGenerator.meshSettings.meshScale
            self.parent = parent
            self.coord = coord
            
            self.position = SIMD2<Float>(coord) * meshWorldSize
            
            self.detailLevels = detailLevels
            
            setVisibility(visible: false)
            
            for i in 0..<detailLevels.count {
                lodMeshes.append(LODMesh(lod: detailLevels[i].lod, callback: self.updateTerrainChunk, parent: parent))
            }
            
            parent.mapGenerator.requestMapData(centre: self.sampleCentre, callback: onMapDataRecieved(mapData:))
        }
        
        func onMapDataRecieved(mapData: HeightMap) {
            self.mapData = mapData
            let positionV3 = SIMD3<Float>(x: self.position.x, y: 0, z: self.position.y)

            node = Terrain()
            node.setPosition(positionV3)
            
            updateTerrainChunk()
        }
        
        func updateTerrainChunk() {
            guard let mapData = self.mapData, let node = self.node else { return }
            
            // Get distance to nearest bound
            let viewDstFromNearestEdge = distance(sampleCentre, parent.viewerPosition!)
            let wasVisible = self.visibility
            let visible = viewDstFromNearestEdge <= parent.maxViewDistance
            
            if visible {
                var lodIdx = 0

                for i in 0..<detailLevels.count {
                    if viewDstFromNearestEdge > detailLevels[i].visibleDstThreshold {
                        lodIdx += 1
                    } else {
                        break
                    }
                }
                
                if lodIdx != previousLodIdx {
                    let lodMesh = lodMeshes[lodIdx]
                    
                    if let mesh = lodMesh.mesh {
                        previousLodIdx = lodIdx
                        node.setMesh(mesh)
                    } else if !self.lodMeshes[lodIdx].hasRequestedMesh {
                        lodMesh.requestMesh(mapData: mapData)
                    }
                }
            }
            
            if wasVisible != visible {
                if (visible) {
                    self.parent.visibleTerrainChunks.append(self)
                } else {
                    self.parent.visibleTerrainChunks.removeAll { (terrainChunk) -> Bool in
                        self === terrainChunk
                    }
                }
                setVisibility(visible: visible)
            }
        }
        
        public func setVisibility(visible: Bool) {
            self.visibility = visible
        }
        
        public func getVisibility() -> Bool {
            return self.visibility
        }
    }
    
    class LODMesh {
        var lod: Int
        var updateCallback: () -> ()
        var parent: EndlessTerrain
        
        var hasRequestedMesh = false
        var mesh: Terrain_CustomMesh!
        
        init(lod: Int, callback: @escaping () -> (), parent: EndlessTerrain) {
            self.lod = lod
            self.updateCallback = callback
            self.parent = parent
        }
        
        public func requestMesh(mapData: HeightMap) {
            self.hasRequestedMesh = true
            
            self.parent.queue.async {
                self.mesh = Terrain_CustomMesh(heightMap: mapData.values, levelOfDetail: self.lod, settings: self.parent.mapGenerator.meshSettings)
                
                DispatchQueue.main.async {
                    self.updateCallback()
                }
            }
        }
    }
    
    struct LODInfo {
        var lod: Int
        var visibleDstThreshold: Float
    }
}
