func nearZero(value: Float) -> Bool {
    let eps: Float = 1.0e-8
    return value < 0.0 ? -value < eps : value < eps
}
