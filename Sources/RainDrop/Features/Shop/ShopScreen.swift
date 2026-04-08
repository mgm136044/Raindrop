import SwiftUI

struct ShopScreen: View {
    @ObservedObject var viewModel: ShopViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String

    init(viewModel: ShopViewModel) {
        self.viewModel = viewModel
        self._selectedCategory = State(initialValue: ShopCatalog.categories.first ?? "기본")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            categoryPicker
            itemGrid
        }
        .frame(minWidth: 500, minHeight: 480)
    }

    private var header: some View {
        ZStack {
            Text("상점")
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

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.categories, id: \.self) { category in
                Button(category) {
                    selectedCategory = category
                }
                .buttonStyle(.glass)
                .tint(selectedCategory == category ? AppColors.accentBlue : .secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4), spacing: 14) {
                ForEach(viewModel.items(for: selectedCategory)) { item in
                    ShopItemCard(
                        item: item,
                        isPurchased: viewModel.isPurchased(item),
                        canAfford: viewModel.canAfford(item),
                        onPurchase: { viewModel.purchase(item) }
                    )
                }
            }
            .padding(20)
        }
    }
}

struct ShopItemCard: View {
    let item: ShopItem
    let isPurchased: Bool
    let canAfford: Bool
    let onPurchase: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text(item.emoji)
                .font(.system(size: 40))

            Text(item.name)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)

            Text(item.description)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if isPurchased {
                Text("보유 중")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(AppColors.accent.opacity(0.12))
                    .clipShape(Capsule())
            } else {
                Button {
                    onPurchase()
                } label: {
                    HStack(spacing: 4) {
                        Text("🪣")
                            .font(.system(size: 11))
                        Text("\(item.price)")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                }
                .buttonStyle(.glassProminent)
                .tint(canAfford ? AppColors.accent : AppColors.tertiaryText)
                .disabled(!canAfford)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(AppColors.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isPurchased ? AppColors.accent.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}
