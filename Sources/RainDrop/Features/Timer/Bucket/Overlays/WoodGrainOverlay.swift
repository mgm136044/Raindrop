import SwiftUI

struct WoodGrainOverlay: View {
    let rect: CGRect

    var body: some View {
        Canvas { context, size in
            let grainColor = Color(red: 0.40, green: 0.25, blue: 0.12).opacity(0.12)
            let lineCount = 8
            let spacing = rect.height / Double(lineCount + 1)
            for i in 1...lineCount {
                let y = spacing * Double(i)
                var path = Path()
                path.move(to: CGPoint(x: rect.width * 0.18, y: y))
                path.addQuadCurve(
                    to: CGPoint(x: rect.width * 0.82, y: y + 1.5),
                    control: CGPoint(x: rect.width * 0.5, y: y + (i.isMultiple(of: 2) ? 2.5 : -1.5))
                )
                context.stroke(path, with: .color(grainColor), lineWidth: 0.8)
            }
            // Center vertical join line
            var joinLine = Path()
            joinLine.move(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.10))
            joinLine.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.92))
            context.stroke(joinLine, with: .color(Color(red: 0.40, green: 0.25, blue: 0.12).opacity(0.18)), lineWidth: 1.0)
        }
        .frame(width: rect.width, height: rect.height)
        .allowsHitTesting(false)
    }
}
