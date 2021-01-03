class View {
    var bottomAnchor: ViewYAxisAnchor!
    var topAnchor: ViewYAxisAnchor!
    var leadingAnchor: ViewXAxisAnchor!
    var trailingAnchor: ViewXAxisAnchor!
    var widthAnchor: ViewDimensionAnchor!
    var heightAnchor: ViewDimensionAnchor!
    
    public var frame: Frame
    
    private var _id: Int
    private var _constraintsNeedUpdating: Bool = false
    private var _constraints: [ViewConstraint] = []
    
    private static var baseId: Int = 0
    
    init() {
        self._id = View.nextId()
        self.frame = Frame(minX: Variable(name: "\(_id).minX"),
                           minY: Variable(name: "\(_id).minY"),
                           width: Variable(name: "\(_id).width"),
                           height: Variable(name: "\(_id).height"))

        self.bottomAnchor = ViewYAxisAnchor(parent: self, anchorType: .bottom)
        self.topAnchor = ViewYAxisAnchor(parent: self, anchorType: .top)
        self.leadingAnchor = ViewXAxisAnchor(parent: self, anchorType: .leading)
        self.trailingAnchor = ViewXAxisAnchor(parent: self, anchorType: .trailing)
        self.widthAnchor = ViewDimensionAnchor(parent: self, anchorType: .width)
        self.heightAnchor = ViewDimensionAnchor(parent: self, anchorType: .height)
    }
    
    public func addConstraints(_ constraints: [ViewConstraint]) {
        self._constraints.append(contentsOf: constraints)
        self._constraintsNeedUpdating = true
    }
    
    public func removeConstraints(_ constraints: [ViewConstraint]) {
        for queryConstraint in constraints {
            self._constraints.removeAll { (vc) -> Bool in
                vc.id() == queryConstraint.id()
            }
        }
        self._constraintsNeedUpdating = true
    }
    
    public func getConstraints() -> [ViewConstraint] {
        return self._constraints
    }
    
    internal func updateConstraints() {}
    
    final func doUpdateConstraints() {
        print("DOING UPDATE")
        self.updateConstraints()
        self._constraintsNeedUpdating = false
    }
    
    func render() {
        printElements(elements: self.frame)
    }
    
    func printElements(elements: Frame...) {
        for element in elements {
            for (_, attr) in Mirror(reflecting: element).children.enumerated() {
                if let propName = attr.label, let value = attr.value as? Variable {
                    print("Attr \(value.name()): \(propName) = \(value.value())")
                }
            }
            print("---")
        }
    }
    
    func getConstraintsNeedsUpdating() -> Bool {
        return self._constraintsNeedUpdating
    }
    
    func setConstraintsNeedsUpdating() {
        self._constraintsNeedUpdating = true
    }
    
    func id() -> Int {
        return self._id
    }
    
    private static func nextId() -> Int {
        let id = View.baseId
        View.baseId += 1
        return id
    }
    
    struct Frame {
        var minX: Variable
        var minY: Variable
        var width: Variable
        var height: Variable
    }
}
