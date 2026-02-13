import SwiftUI
internal import Combine

struct RenderSettings {
    var x: Float = 0
    var y: Float = 0
    var z: Float = 0
    var rx: Float = 0
    var ry: Float = 0
    var rz: Float = 0
    var scale: Float = 1.0
}

class Engine: ObservableObject {
    @Published var settings = RenderSettings() {
        didSet {
            update()
        }
    }
    
    let ctx: Renderer
    var camera: Camera
    
    var b: Box
    var b2: Box
    
    init() {
        self.camera = Camera(fovy: 45)
        
        self.camera.transform.position = Vec3(0, 0, -5)
        
        self.ctx = Renderer(camera: self.camera)
        self.b = Box(x: 0, y: 0, z: 0, size: 1)
        self.b2 = Box(x: 0, y: 0, z: 0, size: 2)
        
        setup()
    }
    
    func setup() {
        self.b2.mesh.wireframe = true
        
        ctx.insert(mesh: self.b2.mesh)
        ctx.insert(mesh: self.b.mesh)
    }
    
    func update() {
        b.mesh.transform.position = Vec3(settings.x, settings.y, settings.z)
        b.mesh.transform.rotation = Vec3(settings.rx, settings.ry, settings.rz)
        b.mesh.transform.scale = Vec3(settings.scale, settings.scale, settings.scale)
        
        b2.mesh.transform.position = Vec3(settings.x, settings.y, settings.z)
        b2.mesh.transform.rotation = Vec3(settings.rx, settings.ry, settings.rz)
        b2.mesh.transform.scale = Vec3(settings.scale, settings.scale, settings.scale)
    }
}


struct ContentView: View {
    @StateObject private var engine = Engine()
    
    @State var x: Float = 0
    @State var y: Float = 0
    @State var a: Float = 0
    
    @State private var lastKey: String = ""
    
    let MAX: Float = 5
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MetalView(ctx: engine.ctx).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12)  {
                // Position Component
                HStack(spacing: 8) {
                    Slider(value: $engine.settings.x, in: -MAX...MAX) {
                        Text("Position X").font(.callout)
                    }.frame(maxWidth: 180)
                    
                    Slider(value: $engine.settings.y, in: -MAX...MAX) {
                        Text("Y").font(.callout)
                    }.frame(maxWidth: 180)
                    
                    Slider(value: $engine.settings.z, in: -MAX...MAX) {
                        Text("Z").font(.callout)
                    }.frame(maxWidth: 180)
                }
                // Rotation Component
                HStack(spacing: 8) {
                    Slider(value: $engine.settings.rx, in: -MAX...MAX) {
                        Text("Rotation X").font(.callout)
                    }.frame(maxWidth: 180)
                    
                    Slider(value: $engine.settings.ry, in: -MAX...MAX) {
                        Text("Y").font(.callout)
                    }.frame(maxWidth: 180)
                    
                    Slider(value: $engine.settings.rz, in: -MAX...MAX) {
                        Text("Z").font(.callout)
                    }.frame(maxWidth: 180)
                }
                
                HStack(spacing: 8) {
                    Slider(value: $engine.settings.scale, in: 0...MAX) {
                        Text("Scale").font(.callout)
                    }.frame(maxWidth: 180)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Position: X \(engine.settings.x) Y \(engine.settings.y) Z \(engine.settings.z)").font(.footnote)
                    Text("Rotation: X \(engine.settings.rx) Y \(engine.settings.ry) Z \(engine.settings.rz)").font(.footnote)
                    Text("Scale:  \(engine.settings.scale)").font(.footnote)

                }
            }.padding(8)
        }
        .focusable()
        .onKeyPress { keyPress in
            lastKey = keyPress.characters
            print("Pressed: \(keyPress.key)")
            return .handled
        }
    }
}

//
//#Preview {
//    ContentView()
//}
