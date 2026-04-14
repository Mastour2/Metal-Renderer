import MetalKit

struct TextureSystem {
    private var texture: Texture

    init(texture: Texture) {
        self.texture = texture
    }

    init(name: String, ext: String = "png", origin: TextureOrigin = .topLeft) {
        self.texture = Texture(name: name, ext: ext, origin: origin)
    }

    func load(device: MTLDevice) -> MTLTexture? {
        let loader = MTKTextureLoader(device: device)

        guard
            let url = Bundle.module.url(
                forResource: texture.name,
                withExtension: texture.ext
            )
        else {
            print("Texture not found: \(texture.name)")
            return nil
        }

        let options: [MTKTextureLoader.Option: Any] = [
            .origin: texture.origin.mtkOrigin,
            .SRGB: false,
        ]

        do {
            return try loader.newTexture(URL: url, options: options)
        } catch {
            print("Texture load failed: \(error)")
            return nil
        }
    }
}
