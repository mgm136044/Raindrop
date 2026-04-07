import SwiftUI

struct HistoryScreen: View {
    @ObservedObject var viewModel: HistoryViewModel
    var skin: BucketSkin = .wood
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: HistoryTab = .monthly

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                if viewModel.isEmpty {
                    ScrollView { emptyState }
                } else {
                    tabContent
                }
            }
            .navigationTitle("집중 히스토리")
        }
        .frame(minWidth: 620, minHeight: 580)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("집중 히스토리")
                        .font(.system(size: 24, weight: .bold))
                    Text("저장된 세션을 날짜별로 확인합니다.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("닫기") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }

            if !viewModel.isEmpty {
                Picker("", selection: $selectedTab) {
                    Text("월간").tag(HistoryTab.monthly)
                    Text("주간").tag(HistoryTab.weekly)
                    Text("세션 기록").tag(HistoryTab.sessions)
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .background(AppColors.historyHeaderBackground)
    }

    // MARK: - Tab Content

    private var tabContent: some View {
        ScrollView {
            switch selectedTab {
            case .monthly:
                CalendarHeatmapView(
                    dailyData: viewModel.dailyTotals,
                    dateService: viewModel.dateService,
                    dailyBucketCounts: viewModel.dailyBucketCounts,
                    skin: skin
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

            case .weekly:
                WeeklyDensityView(
                    dailyData: viewModel.dailyTotals,
                    dailyBucketCounts: viewModel.dailyBucketCounts,
                    dateService: viewModel.dateService,
                    skin: skin
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

            case .sessions:
                historyList
                    .padding(.top, 12)
            }
        }
    }

    // MARK: - Session List

    private var historyList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.summaries) { summary in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(summary.displayDate)
                            .font(.system(size: 15, weight: .bold))
                        Spacer()
                        Text(TimeFormatter.clockString(from: summary.totalSeconds))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.accentBlue)
                    }

                    ForEach(summary.sessions) { session in
                        HStack {
                            Text(viewModel.timeRangeText(for: session))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(TimeFormatter.clockString(from: session.durationSeconds))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.historySessionTime)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(16)
                .background(AppColors.panelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "drop")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.historyIcon)

            Text("아직 저장된 집중 기록이 없습니다.")
                .font(.system(size: 18, weight: .bold))

            Text("첫 세션을 완료하면 여기에서 날짜별 기록을 볼 수 있습니다.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            if let error = viewModel.latestError {
                Text(error)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}

// MARK: - Tab Enum

private enum HistoryTab: String, CaseIterable {
    case monthly
    case weekly
    case sessions
}
