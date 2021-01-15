import UIKit
import GameController

class ViewController : UIViewController {
    var lockedPointer: Bool = true
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersPointerLocked: Bool {
        return lockedPointer
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let centre = NotificationCenter.default
        let main = OperationQueue.main
        
        centre.addObserver(forName: NSNotification.Name.GCMouseDidConnect, object: nil, queue: main) { (note) in
            guard let mouse = note.object as? GCMouse else { return }
            MouseController.setMouse(mouse: mouse)
            print("CONNECTED MOUSE")
        }
        
        centre.addObserver(forName: NSNotification.Name.GCKeyboardDidConnect, object: nil, queue: main) { (note) in
            guard let keyboard = note.object as? GCKeyboard else { return }
            KeyboardController.setKeyboard(keyboard: keyboard)
            print("CONNECTED KEYBOARD")
        }
    }
    
    func changeLock(newState: Bool) {
        self.lockedPointer = newState
        self.setNeedsUpdateOfPrefersPointerLocked()
    }
}
