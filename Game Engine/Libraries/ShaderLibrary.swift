import MetalKit

enum VertexShaderTypes {
    case Basic
}

enum FragmentShaderTypes {
    case Basic
}


class ShaderLibrary {
    public static var defaultLibrary: MTLLibrary!
    
    private static var vertexShaders: [VertexShaderTypes: Shader] = [:]
    private static var fragmentShaders: [FragmentShaderTypes: Shader] = [:]
    
    public static func initialize() {
        defaultLibrary = Engine.device.makeDefaultLibrary()
        createDefaultShaders()
    }
    
    public static func createDefaultShaders() {
        vertexShaders.updateValue(Basic_VertexShader(), forKey: .Basic)
        fragmentShaders.updateValue(Basic_FragmentShader(), forKey: .Basic)
    }
    
    public static func vertex(_ vertexShaderType: VertexShaderTypes) -> MTLFunction {
        return vertexShaders[vertexShaderType]!.function
    }
    
    public static func fragment(_ fragmentShaderType: FragmentShaderTypes) -> MTLFunction {
        return fragmentShaders[fragmentShaderType]!.function
    }
}

protocol Shader {
    var name: String { get }
    var functionName: String { get }
    var function: MTLFunction { get }
}

public struct Basic_VertexShader: Shader {
    public var name: String = "Basic Vertex Shader"
    public var functionName: String = "basic_vertex_shader"
    public var function: MTLFunction {
        let fn = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        fn?.label = name
        return fn!
    }
}

public struct Basic_FragmentShader: Shader {
    public var name: String = "Basic Fragment Shader"
    public var functionName: String = "basic_fragment_shader"
    public var function: MTLFunction {
        let fn = ShaderLibrary.defaultLibrary.makeFunction(name: functionName)
        fn?.label = name
        return fn!
    }
}
