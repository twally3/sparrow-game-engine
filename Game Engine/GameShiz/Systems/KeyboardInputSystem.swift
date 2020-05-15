import MetalKit

class KeyboardInputSystem: System {
    var priority: Int
    var entities: [Entity] = []
    var engine: ECS!
    
    let family = Family.all(components: KeyboardInputComponent.self)
    
    init(priority: Int) {
        self.priority = priority
    }
    
    func update(deltaTime: Float) {
        for entity in entities {
            let keyboardComp = entity.getComponent(componentClass: KeyboardInputComponent.self) as! KeyboardInputComponent
            
            keyboardComp.space = Keyboard.isKeyPressed(.space)
            keyboardComp.returnKey = Keyboard.isKeyPressed(.returnKey)
            keyboardComp.enterKey = Keyboard.isKeyPressed(.enterKey)
            keyboardComp.escape = Keyboard.isKeyPressed(.escape)
            keyboardComp.shift = Keyboard.isKeyPressed(.shift)
            keyboardComp.command = Keyboard.isKeyPressed(.command)

            keyboardComp.leftArrow = Keyboard.isKeyPressed(.leftArrow)
            keyboardComp.rightArrow = Keyboard.isKeyPressed(.rightArrow)
            keyboardComp.downArrow = Keyboard.isKeyPressed(.downArrow)
            keyboardComp.upArrow = Keyboard.isKeyPressed(.upArrow)

            keyboardComp.a = Keyboard.isKeyPressed(.a)
            keyboardComp.b = Keyboard.isKeyPressed(.b)
            keyboardComp.c = Keyboard.isKeyPressed(.c)
            keyboardComp.d = Keyboard.isKeyPressed(.d)
            keyboardComp.e = Keyboard.isKeyPressed(.e)
            keyboardComp.f = Keyboard.isKeyPressed(.f)
            keyboardComp.g = Keyboard.isKeyPressed(.g)
            keyboardComp.h = Keyboard.isKeyPressed(.h)
            keyboardComp.i = Keyboard.isKeyPressed(.i)
            keyboardComp.j = Keyboard.isKeyPressed(.j)
            keyboardComp.k = Keyboard.isKeyPressed(.k)
            keyboardComp.l = Keyboard.isKeyPressed(.l)
            keyboardComp.m = Keyboard.isKeyPressed(.m)
            keyboardComp.n = Keyboard.isKeyPressed(.n)
            keyboardComp.o = Keyboard.isKeyPressed(.o)
            keyboardComp.p = Keyboard.isKeyPressed(.p)
            keyboardComp.q = Keyboard.isKeyPressed(.q)
            keyboardComp.r = Keyboard.isKeyPressed(.r)
            keyboardComp.s = Keyboard.isKeyPressed(.s)
            keyboardComp.t = Keyboard.isKeyPressed(.t)
            keyboardComp.u = Keyboard.isKeyPressed(.u)
            keyboardComp.v = Keyboard.isKeyPressed(.v)
            keyboardComp.w = Keyboard.isKeyPressed(.w)
            keyboardComp.x = Keyboard.isKeyPressed(.x)
            keyboardComp.y = Keyboard.isKeyPressed(.y)
            keyboardComp.z = Keyboard.isKeyPressed(.z)

            keyboardComp.zero = Keyboard.isKeyPressed(.zero)
            keyboardComp.one = Keyboard.isKeyPressed(.one)
            keyboardComp.two = Keyboard.isKeyPressed(.two)
            keyboardComp.three = Keyboard.isKeyPressed(.three)
            keyboardComp.four = Keyboard.isKeyPressed(.four)
            keyboardComp.five = Keyboard.isKeyPressed(.five)
            keyboardComp.six = Keyboard.isKeyPressed(.six)
            keyboardComp.seven = Keyboard.isKeyPressed(.seven)
            keyboardComp.eight = Keyboard.isKeyPressed(.eight)
            keyboardComp.nine = Keyboard.isKeyPressed(.nine)
            
            keyboardComp.keypad0 = Keyboard.isKeyPressed(.keypad0)
            keyboardComp.keypad1 = Keyboard.isKeyPressed(.keypad1)
            keyboardComp.keypad2 = Keyboard.isKeyPressed(.keypad2)
            keyboardComp.keypad3 = Keyboard.isKeyPressed(.keypad3)
            keyboardComp.keypad4 = Keyboard.isKeyPressed(.keypad4)
            keyboardComp.keypad5 = Keyboard.isKeyPressed(.keypad5)
            keyboardComp.keypad6 = Keyboard.isKeyPressed(.keypad6)
            keyboardComp.keypad7 = Keyboard.isKeyPressed(.keypad7)
            keyboardComp.keypad8 = Keyboard.isKeyPressed(.keypad8)
            keyboardComp.keypad9 = Keyboard.isKeyPressed(.keypad9)
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {}
    
    func onEntityAdded(entity: Entity) {
        if family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
        }
    }
    
    func onEntityRemoved(entity: Entity) {
        if !family.matches(entity: entity) {
            self.entities = engine.getEntities(for: family)
        }
    }
    
    func onAddedToEngine(engine: ECS) {
        self.entities = engine.getEntities(for: family)
        self.engine = engine
    }
}
