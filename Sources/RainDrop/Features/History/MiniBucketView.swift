import SwiftUI

struct MiniBucketView: View {
    let fillRatio: Double
    let skin: BucketSkin
    var tappable: Bool = false

    @State private var wobbleAngle: Double = 0
    @State private var waterTilt: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Bucket outline
                BucketShape()
                    .fill(skin.bucketFill.opacity(0.5))

                // Water fill with tilt response
                if fillRatio > 0 {
                    WaterSurfaceShape(
                        progress: fillRatio,
                        waveOffset: 0,
                        intensity: 0,
                        layer: .front,
                        tiltAngle: waterTilt
                    )
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.waterGradientTopColor.opacity(0.7),
                                AppColors.waterGradientBottomColor.opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(BucketShape().scale(0.86))
                }

                // Bucket stroke
                BucketShape()
                    .stroke(skin.bucketStroke.opacity(0.6), lineWidth: 1.5)
            }
            .rotationEffect(.degrees(wobbleAngle), anchor: .bottom)
            .animation(.interpolatingSpring(stiffness: 300, damping: 8), value: wobbleAngle)
            .animation(.interpolatingSpring(stiffness: 300, damping: 8), value: waterTilt)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard tappable else { return }
            wobbleAngle = 6
            waterTilt = 6
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                wobbleAngle = 0
                waterTilt = 0
            }
        }
    }
}
