class ViewAnchor<AnchorType> {
    public unowned let parent: View
    public let anchorType: AnchorTypes
    
    init(parent: View, anchorType: AnchorTypes) {
        self.parent = parent
        self.anchorType = anchorType
    }
    
    public func constraint(equalTo toItem: ViewAnchor<AnchorType>, constant: Float = 0, multiplier: Float = 1) -> ViewConstraint {
        return self.createConstraint(item: toItem,
                                     constant: constant,
                                     multiplier: multiplier,
                                     relation: .equal)
    }
    
    public func constraint(greaterThanOrEqual toItem: ViewAnchor<AnchorType>, constant: Float = 0, multiplier: Float = 1) -> ViewConstraint {
        return self.createConstraint(item: toItem,
                                     constant: constant,
                                     multiplier: multiplier,
                                     relation: .greaterThanOrEqual)
    }
    
    public func constraint(lessThanOrEqual toItem: ViewAnchor<AnchorType>, constant: Float = 0, multiplier: Float = 1) -> ViewConstraint {
        return self.createConstraint(item: toItem,
                                     constant: constant,
                                     multiplier: multiplier,
                                     relation: .lessThanOrEqual)
    }
    
    public func constraint(equalToConstant constant: Float) -> ViewConstraint {
        return self.createConstraint(item: nil, constant: constant, multiplier: 1, relation: .equal)
    }
    
    public func constraint(greaterThanOrEqualToConstant constant: Float) -> ViewConstraint {
        return self.createConstraint(item: nil, constant: constant, multiplier: 1, relation: .greaterThanOrEqual)
    }
    
    public func constraint(lessThanOrEqualToConstant constant: Float) -> ViewConstraint {
        return self.createConstraint(item: nil, constant: constant, multiplier: 1, relation: .lessThanOrEqual)
    }
    
    private func createConstraint(item: ViewAnchor<AnchorType>?, constant: Float, multiplier: Float, relation: AnchorRelations) -> ViewConstraint {
        return ViewConstraint(fromItem: self.parent,
                              fromAttribute: self.anchorType,
                              relatedBy: relation,
                              toItem: item?.parent,
                              toAttribute: item?.anchorType,
                              multiplier: multiplier,
                              constant: constant)
    }
}

class ViewYAxisAnchor : ViewAnchor<ViewYAxisAnchor> {}
class ViewXAxisAnchor : ViewAnchor<ViewXAxisAnchor> {}
class ViewDimensionAnchor : ViewAnchor<ViewDimensionAnchor> {}

enum AnchorTypes {
    case leading
    case trailing
    case top
    case bottom
    case width
    case height
    case centreX
    case centreY
}

enum AnchorRelations {
    case equal
    case greaterThanOrEqual
    case lessThanOrEqual
}
