import SwiftUI

struct RivetOverlay: View {
    let rect: CGRect
    let rivetColor: Color
    let count: Int

    init(rect: CGRect, rivetColor: Color = Color(red: 0.55, green: 0.58, blue: 0.62), count: Int = 3) {
        self.rect = rect
        self.rivetColor = rivetColor
        self.count = count
    }

    var body: some View {
        Canvas { context, size in
            let topY = rect.height * 0.06
            let sideInset = rect.width * 0.10
            let rimWidth = rect.width - sideInset * 2
            let rivetSize: CGFloat = 4.0
            let spacing = rimWidth / Double(count + 1)

            for i in 1...count {
                let x = sideInset + spacing * Double(i)
                let center = CGPoint(x: x, y: topY + 6)
                let outer = Path(ellipseIn: CGRect(
                    x: center.x - rivetSize / 2,
                    y: center.y - rivetSize / 2,
                    width: rivetSize,
                    height: rivetSize
                ))
                context.fill(outer, with: .color(rivetColor))
                let inner = Path(ellipseIn: CGRect(
                    x: center.x - rivetSize / 4,
                    y: center.y - rivetSize / 4,
                    width: rivetSize / 2,
                    height: rivetSize / 2
                ))
                context.fill(inner, with: .color(rivetColor.opacity(0.5)))
            }
        }
        .frame(width: rect.width, height: rect.height)
        .allowsHitTesting(false)
    }
}
