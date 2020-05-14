class LightComponent: Component {
    var colour: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    var brightness: Float = 1.0
    var ambientIntensity: Float = 1.0
    var diffuseIntensity: Float = 1.0
    var specularIntensity: Float = 1.0
    
    init(colour: SIMD3<Float> = SIMD3<Float>(repeating: 1),
         brightness: Float = 1.0,
         ambientIntensity: Float = 1.0,
         diffuseIntensity: Float = 1.0,
         specularIntensity: Float = 1.0) {
        self.colour = colour
        self.brightness = brightness
        self.ambientIntensity = ambientIntensity
        self.diffuseIntensity = diffuseIntensity
        self.specularIntensity = specularIntensity
    }
}
