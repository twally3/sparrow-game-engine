import UIKit
import GameController

class ViewController : UIViewController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let centre = NotificationCenter.default
        let main = OperationQueue.main
        
        centre.addObserver(forName: NSNotification.Name.GCKeyboardDidConnect, object: nil, queue: main) { (note) in
            guard let keyboard = note.object as? GCKeyboard else { return }
            KeyboardController.setKeyboard(keyboard: keyboard)
            print("CONNECTED")
        }
    }
}
