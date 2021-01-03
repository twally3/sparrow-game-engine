class Window : View {
    public private(set) var width: Float
    public private(set) var height: Float
    
    init(width: Float, height: Float) {
        self.width = width
        self.height = height
        
        super.init()
        
        self.setConstraintsNeedsUpdating()
    }
    
    override func updateConstraints() {
        self.removeConstraints(self.getConstraints())
        
        self.addConstraints([
            self.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            self.leadingAnchor.constraint(equalToConstant: 0),
            self.topAnchor.constraint(equalToConstant: 0),
            self.widthAnchor.constraint(equalToConstant: self.width),
            self.heightAnchor.constraint(equalToConstant: self.height),
        ])
    }
    
    public func updateFrame(width: Float, height: Float) {
        self.width = width
        self.height = height
        self.setConstraintsNeedsUpdating()
    }
}
