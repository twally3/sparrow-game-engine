import GameController

class KeyboardController {
    private static var keyboard: GCKeyboard? = nil
    
    public static func setKeyboard(keyboard: GCKeyboard) {
        KeyboardController.keyboard = keyboard
    }
    
    public static func isPressed(keyCode: GCKeyCode) -> Bool {
        guard let keyboard = KeyboardController.keyboard else { return false }
        return keyboard.keyboardInput?.button(forKeyCode: keyCode)?.isPressed ?? false
    }
}
