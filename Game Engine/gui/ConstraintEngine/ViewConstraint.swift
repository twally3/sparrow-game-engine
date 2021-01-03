class ViewConstraint {
    var fromItem: View
    var fromAttribute: AnchorTypes
    var relatedBy: AnchorRelations
    var toitem: View?
    var toAttribute: AnchorTypes?
    var multiplier: Float
    var constant: Float
    
    private var _id: Int
    private static var baseId: Int = 0
    
    init(fromItem: View, fromAttribute: AnchorTypes, relatedBy: AnchorRelations, toItem: View?, toAttribute: AnchorTypes?, multiplier: Float = 1, constant: Float = 0) {
        self.fromItem = fromItem
        self.fromAttribute = fromAttribute
        self.relatedBy = relatedBy
        self.toitem = toItem
        self.toAttribute = toAttribute
        self.multiplier = multiplier
        self.constant = constant
        
        self._id = ViewConstraint.getId()
    }
    
    public func id() -> Int {
        return self._id
    }

    private static func getId() -> Int {
        let id = ViewConstraint.baseId
        ViewConstraint.baseId += 1
        return id
    }
}
