import MetalKit

enum TextureOrigin {
    case topLeft, bottomLeft
    var mtkOrigin: MTKTextureLoader.Origin {
        switch self {
        case .topLeft: return .topLeft
        case .bottomLeft: return .bottomLeft
        }
    }
}

struct Texture: Component {
    var name: String
    var ext: String = "png"
    var origin: TextureOrigin = .topLeft
    var mtlTexture: MTLTexture? = nil
}
