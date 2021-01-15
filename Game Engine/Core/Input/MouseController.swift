import GameController

class MouseController {
    private static var mouse: GCMouse? = nil
    
    private static var overallMousePosition = SIMD2<Float>(repeating: 0)
    private static var mousePositionDelta = SIMD2<Float>(repeating: 0)
    
    public static func setMouse(mouse: GCMouse) {
        MouseController.mouse = mouse
        MouseController.registerEvents(mouse: mouse)
    }
    
    public static func setOverallPosition(position: SIMD2<Float>) {
        MouseController.overallMousePosition = position
    }
    
    private static func registerEvents(mouse: GCMouse) {
        guard let mouseInput = mouse.mouseInput else { return }
        
        mouseInput.mouseMovedHandler = { (mouse, deltaX, deltaY) in
            MouseController.mousePositionDelta = SIMD2<Float>(deltaX, -deltaY)
            
            Mouse.setMousePositionChange(overallPosition: MouseController.overallMousePosition,
                                         deltaPosition: MouseController.mousePositionDelta)
        }
        
        mouseInput.leftButton.valueChangedHandler = { (button, value, pressed) in
            Mouse.setMouseButtonPressed(button: 0, isOn: pressed)
        }
        
        mouseInput.rightButton?.valueChangedHandler = { (button, value, pressed) in
            Mouse.setMouseButtonPressed(button: 1, isOn: pressed)
        }
        
        mouseInput.middleButton?.valueChangedHandler = { (button, value, pressed) in
            Mouse.setMouseButtonPressed(button: 2, isOn: pressed)
        }
        
        mouseInput.scroll.valueChangedHandler = { (cursor, x, y) in
            Mouse.scrollMouse(deltaY: y)
        }
    }
}
