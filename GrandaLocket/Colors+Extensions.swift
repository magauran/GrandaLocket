
import SwiftUI

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


extension View {
    func saveAsImage(width: CGFloat, height: CGFloat, _ completion: @escaping (UIImage) -> Void) {
        let size = CGSize(width: width, height: height)

        let controller = UIHostingController(rootView: self.frame(width: width, height: height))
        controller.view.bounds = CGRect(origin: .zero, size: size)
        let image = controller.view.asImage()

        completion(image)
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}

extension UIScreen {
    var width: CGFloat { UIScreen.main.bounds.width }
    var height: CGFloat { UIScreen.main.bounds.height }
}
//Example save as image
//struct ContentView: View {
//
//    var contentToSave: some View {
//        ZStack {
//            Circle()
//                .fill(Color.blue)
//                .frame(width: 150, height: 150)
//                .padding()
//            Text("🤯")
//                .font(.largeTitle)
//        }
//            .background(Color.green.edgesIgnoringSafeArea(.all))
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//    }
//
//    var body: some View {
//        VStack {
//            contentToSave
//            Button("Save Image") {
//                contentToSave.saveAsImage(width: 200, height: 200) { image in
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                }
//            }
//        }
//    }
//}
