import SwiftUI

struct MiniBucketView: View {
    let fillRatio: Double
    let skin: BucketSkin

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Bucket outline
                BucketShape()
                    .fill(skin.bucketFill.opacity(0.5))

                // Water fill (static, no wave animation)
                if fillRatio > 0 {
                    Rectangle()
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
                        .frame(height: geometry.size.height * 0.80 * min(fillRatio, 1.0))
                        .mask(BucketShape().scale(0.86))
                }

                // Bucket stroke
                BucketShape()
                    .stroke(skin.bucketStroke.opacity(0.6), lineWidth: 1.5)
            }
        }
    }
}
