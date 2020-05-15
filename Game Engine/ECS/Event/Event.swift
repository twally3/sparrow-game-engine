public class Event<T> {
    public typealias EventHandler = (T) -> ()
    private var eventHandlers = ContiguousArray<Invocable>()

    public func raise(data: T) {
        for handler in self.eventHandlers {
            handler.invoke(data: data)
        }
    }

    public func addHandler(handler: @escaping (T) -> ()) -> Disposable {
        let wrapper = EventHandlerWrapper(handler: handler, event: self)
        eventHandlers.append(wrapper)
        return wrapper
    }

    private class EventHandlerWrapper<T>: Invocable, Disposable {
        let handler: (T) -> ()
        let event: Event<T>
        
        init(handler: @escaping (T) -> (), event: Event<T>) {
            self.handler = handler
            self.event = event;
        }

        func invoke(data: Any) -> () {
            handler(data as! T)
        }

        func dispose() {
            event.eventHandlers = event.eventHandlers.filter { $0 !== self }
        }
    }
}

private protocol Invocable: class {
    func invoke(data: Any)
}

public protocol Disposable {
    func dispose()
}
