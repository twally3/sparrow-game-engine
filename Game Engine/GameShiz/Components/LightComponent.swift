class LightComponent: Component {
    var colour: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    var brightness: Float = 1.0
    var ambientIntensity: Float = 1.0
    var diffuseIntensity: Float = 1.0
    var specularIntensity: Float = 1.0
}
