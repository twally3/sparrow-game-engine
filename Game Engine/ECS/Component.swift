protocol Component {}

extension Component {
    static var classIdentifier: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}
