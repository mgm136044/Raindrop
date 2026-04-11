import SwiftUI

struct ScaleMarkingsOverlay: View {
    let rect: CGRect
    let markingColor: Color

    init(rect: CGRect, markingColor: Color = Color(red: 0.62, green: 0.64, blue: 0.66)) {
        self.rect = rect
        self.markingColor = markingColor
    }

    var body: some View {
        Canvas { context, size in
            let bottomY = rect.height * 0.95
            let startY = rect.height * 0.85
            let markCount = 5
            let spacing = (bottomY - startY) / Double(markCount)
            let leftX = rect.width * 0.14
            let markWidth: CGFloat = 8

            for i in 0..<markCount {
                let y = startY + spacing * Double(i)
                var line = Path()
                line.move(to: CGPoint(x: leftX + 4, y: y))
                line.addLine(to: CGPoint(x: leftX + 4 + markWidth, y: y))
                context.stroke(
                    line,
                    with: .color(markingColor.opacity(0.3)),
                    lineWidth: i.isMultiple(of: 2) ? 1.0 : 0.5
                )
            }
        }
        .frame(width: rect.width, height: rect.height)
        .allowsHitTesting(false)
    }
}
