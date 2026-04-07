import SwiftUI

struct BucketWithStickersView: View {
    let progress: Double
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    var intensity: Double = 0.5
    var waterColorOverride: (top: Color, bottom: Color)?
    let placements: [StickerPlacement]
    let isDecorating: Bool
    let onAddPlacement: (StickerPlacement) -> Void
    let onRemovePlacement: (UUID) -> Void
    let purchasedItems: Set<String>

    @State private var wobbleAngle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BucketView(progress: progress, skin: skin, useCustomWaterColor: useCustomWaterColor, intensity: intensity, waterColorOverride: waterColorOverride)

                // Sticker overlays
                ForEach(placements) { placement in
                    if let item = ShopCatalog.item(for: placement.itemID) {
                        stickerView(item: item, placement: placement, in: geometry.size)
                    }
                }
            }
            .rotationEffect(.degrees(wobbleAngle), anchor: .bottom)
            .overlay {
                if !isDecorating {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            wobbleAngle = 6
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 8)) {
                                wobbleAngle = 0
                            }
                        }
                }
            }
            .dropDestination(for: String.self) { items, location in
                guard isDecorating, let itemID = items.first else { return false }
                let relativeX = location.x / geometry.size.width
                let relativeY = location.y / geometry.size.height
                let placement = StickerPlacement(
                    itemID: itemID,
                    relativeX: min(max(relativeX, 0.05), 0.95),
                    relativeY: min(max(relativeY, 0.05), 0.95)
                )
                onAddPlacement(placement)
                return true
            }
        }
    }

    private func stickerView(item: ShopItem, placement: StickerPlacement, in size: CGSize) -> some View {
        let x = placement.relativeX * size.width
        let y = placement.relativeY * size.height

        return Text(item.emoji)
            .font(.system(size: 26))
            .position(x: x, y: y)
            .overlay(
                Group {
                    if isDecorating {
                        Button {
                            onRemovePlacement(placement.id)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                        .position(x: x + 14, y: y - 14)
                    }
                }
            )
    }
}
