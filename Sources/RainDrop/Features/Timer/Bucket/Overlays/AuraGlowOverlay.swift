import SwiftUI

struct AuraGlowOverlay: View {
    let rect: CGRect
    let glowRadius: CGFloat
    let hueRotation: Double

    init(rect: CGRect, glowRadius: CGFloat = 3.0, hueRotation: Double = 0) {
        self.rect = rect
        self.glowRadius = glowRadius
        self.hueRotation = hueRotation
    }

    var body: some View {
        RoundedRectangle(cornerRadius: rect.width * 0.08)
            .strokeBorder(
                AngularGradient(
                    colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .red],
                    center: .center
                ),
                lineWidth: glowRadius
            )
            .frame(width: rect.width + glowRadius * 2, height: rect.height + glowRadius * 2)
            .blur(radius: glowRadius)
            .opacity(0.35)
            .hueRotation(.degrees(hueRotation))
            .allowsHitTesting(false)
    }
}
