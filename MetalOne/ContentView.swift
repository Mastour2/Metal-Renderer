import SwiftUI


struct ContentView: View {
    var ctx: Renderer
    
    @State var x: Float = 0
    
    init() {
        let camera = Camera(fovy: 45)
        
        ctx = Renderer(camera: camera)
    
        
        let rect = Rect(x: -1.5, y: 0, z: 0, w: 1, h: 1)
        ctx.insert(mesh: rect.mesh)
        
        
        let circle = Circle(x: -1.5, y: 0, z: -0.1, rad: 0.5)
        circle.mesh.wireframe = true
        ctx.insert(mesh: circle.mesh)
        
        
        let box1 = Box(x: 1.5, y: 0, z: 0, w: 1, h: 1)
        box1.mesh.wireframe = true
        ctx.insert(mesh: box1.mesh)
        
        let box2 = Box(x: 0, y: 0, z: 0, w: 1, h: 1)
        ctx.insert(mesh: box2.mesh)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MetalView(ctx: ctx).ignoresSafeArea()
            Button {
                x += 0.5
                print(x)
            } label: {
                Text("click")
            }.padding()
        }
    }
}

//
//#Preview {
//    ContentView()
//}
