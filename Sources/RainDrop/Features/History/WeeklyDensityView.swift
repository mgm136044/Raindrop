import SwiftUI

struct WeeklyDensityView: View {
    let dailyData: [String: Int]
    let dailyBucketCounts: [String: Int]
    let dateService: DateService
    let skin: BucketSkin

    @State private var weekOffset: Int = 0
    @State private var animatedFill: Bool = false

    private var weekDays: [CalendarDay] {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()
        guard let startOfWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today),
              let monday = calendar.dateInterval(of: .weekOfYear, for: startOfWeek)?.start
        else { return [] }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else { return nil }
            let key = dateService.dateKey(for: date)
            let seconds = dailyData[key] ?? 0
            let buckets = dailyBucketCounts[key] ?? 0
            return CalendarDay(date: date, dateKey: key, totalSeconds: seconds, bucketCount: buckets)
        }
    }

    private let dayLabels = ["월", "화", "수", "목", "금", "토", "일"]

    private var weekBucketTotal: Int {
        weekDays.reduce(0) { $0 + $1.bucketCount }
    }

    private var weekTotalSeconds: Int {
        weekDays.reduce(0) { $0 + $1.totalSeconds }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Week navigator
            HStack {
                Button {
                    weekOffset -= 1
                    animatedFill = false
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.glass)
                .disabled(weekOffset <= -12)

                Spacer()

                Text(weekRangeText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Button {
                    weekOffset += 1
                    animatedFill = false
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.glass)
                .disabled(weekOffset >= 0)
            }
            .padding(.horizontal, 16)

            // 7 buckets side by side
            HStack(spacing: 10) {
                ForEach(Array(weekDays.enumerated()), id: \.element.id) { index, day in
                    VStack(spacing: 6) {
                        TappableMiniBucket(
                            fillRatio: animatedFill ? day.fillRatio : 0,
                            skin: skin
                        )
                        .frame(width: 52, height: 52)

                        Text(dayLabels[index])
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)

                        Text(TimeFormatter.compactDuration(from: day.totalSeconds))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(AppColors.subtitleText)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 8)

            // Summary
            HStack(spacing: 16) {
                Label("양동이 \(weekBucketTotal)개", systemImage: "drop.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.accentBlue)

                Label(TimeFormatter.compactDuration(from: weekTotalSeconds), systemImage: "clock")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animatedFill = true
            }
        }
        .onChange(of: weekOffset) { _,_ in
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedFill = true
                }
            }
        }
    }

    private static let weekRangeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M/d"
        return f
    }()

    private var weekRangeText: String {
        guard let first = weekDays.first, let last = weekDays.last else { return "" }
        let f = Self.weekRangeFormatter
        return "\(f.string(from: first.date)) ~ \(f.string(from: last.date))"
    }
}

// MARK: - Mini Bucket

private struct TappableMiniBucket: View {
    let fillRatio: Double
    let skin: BucketSkin

    @State private var wobbleAngle: Double = 0

    var body: some View {
        BucketView(
            progress: fillRatio,
            skin: skin,
            useCustomWaterColor: false,
            intensity: 0,
            mode: .mini
        )
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
