import SwiftUI

struct BucketWithStickersView: View {
    let progress: Double
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    var intensity: Double = 0.5
    var waterColorOverride: (top: Color, bottom: Color)?
    let placements: [StickerPlacement]

    @State private var wobbleAngle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BucketView(progress: progress, skin: skin, useCustomWaterColor: useCustomWaterColor, intensity: intensity, waterColorOverride: waterColorOverride)

                // Sticker overlays (read-only)
                ForEach(placements) { placement in
                    if let item = ShopCatalog.item(for: placement.itemID) {
                        Text(item.emoji)
                            .font(.system(size: 26))
                            .position(
                                x: placement.relativeX * geometry.size.width,
                                y: placement.relativeY * geometry.size.height
                            )
                            .allowsHitTesting(false)
                    }
                }
            }
            .rotationEffect(.degrees(wobbleAngle), anchor: .bottom)
            .animation(.interpolatingSpring(stiffness: 300, damping: 8), value: wobbleAngle)
            .contentShape(Rectangle())
            .onTapGesture {
                wobbleAngle = wobbleAngle <= 0 ? 6 : -6
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    wobbleAngle = 0
                }
            }
        }
    }
}
