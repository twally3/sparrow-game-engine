import UIKit
import MetalKit

class GameView: MTKView {

    var renderer: Renderer!

    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        preferredFramesPerSecond = 120

        self.device = MTLCreateSystemDefaultDevice()
//        self.device = MTLCopyAllDevices()[1]
        
        Engine.ignite(device: device!)

        self.clearColor = Preferences.clearColour
        self.colorPixelFormat = Preferences.mainPixelFormat
        self.depthStencilPixelFormat = Preferences.mainDepthPixelFormat

        self.renderer = Renderer(self)
        self.delegate = renderer
        
        self.addInteraction(UIPointerInteraction(delegate: self))
    }
}

extension GameView : UIPointerInteractionDelegate {
    func pointerInteraction(_ interaction: UIPointerInteraction, regionFor request: UIPointerRegionRequest, defaultRegion: UIPointerRegion) -> UIPointerRegion? {
        MouseController.setOverallPosition(position: SIMD2<Float>(Float(request.location.x), Float(request.location.y)))
        return defaultRegion
    }
}
