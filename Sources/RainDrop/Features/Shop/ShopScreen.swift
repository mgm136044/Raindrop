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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("상점")
                    .font(.system(size: 24, weight: .bold))
                Text("양동이를 채워서 스티커를 모으세요!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("🪣")
                    .font(.system(size: 18))
                Text("\(viewModel.balance)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(AppColors.panelBackground)
            .clipShape(Capsule())

            Button("닫기") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .background(AppColors.historyHeaderBackground)
    }

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.categories, id: \.self) { category in
                Button(category) {
                    selectedCategory = category
                }
                .buttonStyle(.bordered)
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
                    .foregroundStyle(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.12))
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
                .buttonStyle(.borderedProminent)
                .tint(canAfford ? AppColors.accentBlue : .gray)
                .disabled(!canAfford)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(AppColors.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isPurchased ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}
