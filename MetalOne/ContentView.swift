import SwiftUI

struct ContentView: View {
    var ctx: Renderer

    
    init() {
        ctx = Renderer()
        
        let rectGeo = RectGeometry(w: 0.2, h: 1.5)
        let rectMesh = Mesh(geo: rectGeo)
        ctx.insert(mesh: rectMesh)
        
        
        let circleGeo = RegularPolygonGeometry(sides: 32, rad: 0.5)
        let circleMesh = Mesh(geo: circleGeo)
        ctx.insert(mesh: circleMesh)
    }
    
    var body: some View {
        VStack {
            MetalView(ctx: ctx).ignoresSafeArea()
        }
    }
}

//
//#Preview {
//    ContentView()
//}
