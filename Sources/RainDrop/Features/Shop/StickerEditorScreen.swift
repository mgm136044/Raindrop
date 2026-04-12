import SwiftUI

struct StickerEditorScreen: View {
    @ObservedObject var shopViewModel: ShopViewModel
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header

            HStack(spacing: 0) {
                // Left: Bucket preview with stickers
                bucketPreview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                // Right: Palette + Placed list
                VStack(spacing: 0) {
                    stickerPalette
                    Divider()
                    placedStickerList
                }
                .frame(width: 220)
            }
        }
        .frame(minWidth: 600, minHeight: 480)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("스티커 편집")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            HStack {
                Spacer()
                Button("완료") { dismiss() }
                    .buttonStyle(.glass)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular)
    }

    // MARK: - Bucket Preview

    private let bucketPreviewWidth: CGFloat = 220
    private let bucketPreviewHeight: CGFloat = 200

    private var bucketPreview: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.rightPanelGradientTop, AppColors.rightPanelGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            GeometryReader { geometry in
                ZStack {
                    BucketView(progress: 0.5, skin: skin, useCustomWaterColor: useCustomWaterColor)
                        .frame(width: bucketPreviewWidth, height: bucketPreviewHeight)

                    ForEach(shopViewModel.shopState.placements) { placement in
                        if let item = ShopCatalog.item(for: placement.itemID) {
                            DraggableStickerView(
                                emoji: item.emoji,
                                relativeX: placement.relativeX,
                                relativeY: placement.relativeY,
                                containerWidth: bucketPreviewWidth,
                                containerHeight: bucketPreviewHeight
                            ) { newX, newY in
                                shopViewModel.updatePlacementPosition(
                                    id: placement.id,
                                    relativeX: newX,
                                    relativeY: newY
                                )
                            }
                        }
                    }
                }
                .frame(width: bucketPreviewWidth, height: bucketPreviewHeight)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }

            // Hint
            VStack {
                Spacer()
                Text("스티커를 드래그하여 위치를 조정하세요")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary.opacity(0.7))
                    .padding(.bottom, 8)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(16)
    }

    // MARK: - Sticker Palette

    private var stickerPalette: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("스티커 추가")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 10)

            let purchased = ShopCatalog.allItems.filter { shopViewModel.isPurchased($0) && $0.category != "배경" }

            if purchased.isEmpty {
                VStack(spacing: 8) {
                    Text("구매한 스티커가 없습니다")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                    Text("상점에서 스티커를 구매해보세요")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                    ForEach(purchased) { item in
                        Button {
                            addStickerToCenter(item)
                        } label: {
                            Text(item.emoji)
                                .font(.system(size: 24))
                                .frame(width: 40, height: 40)
                                .background(AppColors.panelBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
    }

    // MARK: - Placed Sticker List

    private var placedStickerList: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("배치된 스티커")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                Spacer()
                if !shopViewModel.shopState.placements.isEmpty {
                    Button {
                        removeAllPlacements()
                    } label: {
                        Text("전체 삭제")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColors.danger)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 6)

            if shopViewModel.shopState.placements.isEmpty {
                Text("배치된 스티커가 없습니다")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                List {
                    ForEach(shopViewModel.shopState.placements) { placement in
                        if let item = ShopCatalog.item(for: placement.itemID) {
                            HStack(spacing: 10) {
                                Text(item.emoji)
                                    .font(.system(size: 20))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 13, weight: .medium))
                                }

                                Spacer()

                                Button {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        shopViewModel.removePlacement(id: placement.id)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.danger)
                                }
                                .buttonStyle(.glass)
                                .controlSize(.small)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Actions

    private func removeAllPlacements() {
        withAnimation(.easeOut(duration: 0.2)) {
            shopViewModel.removeAllPlacements()
        }
    }

    private func addStickerToCenter(_ item: ShopItem) {
        let placement = StickerPlacement(
            itemID: item.id,
            relativeX: 0.3 + Double.random(in: 0...0.4),
            relativeY: 0.3 + Double.random(in: 0...0.4)
        )
        shopViewModel.addPlacement(placement)
    }
}

// MARK: - Draggable Sticker

private struct DraggableStickerView: View {
    let emoji: String
    let relativeX: Double
    let relativeY: Double
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let onPositionChanged: (Double, Double) -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        Text(emoji)
            .font(.system(size: 26))
            .offset(dragOffset)
            .position(
                x: relativeX * containerWidth,
                y: relativeY * containerHeight
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let newX = relativeX + Double(value.translation.width) / containerWidth
                        let newY = relativeY + Double(value.translation.height) / containerHeight
                        onPositionChanged(newX, newY)
                        dragOffset = .zero
                    }
            )
    }
}
