import SwiftUI

struct CalendarHeatmapView: View {
    let dailyData: [String: Int]
    let dateService: DateService
    let dailyBucketCounts: [String: Int]
    @State private var selectedDay: CalendarDay?
    @State private var displayedMonth: Date = {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: comps) ?? Date()
    }()

    private let cellSpacing: CGFloat = 4
    private let cellHeight: CGFloat = 40
    private let dayHeaders = ["월", "화", "수", "목", "금", "토", "일"]

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("집중 달력")
                .font(.system(size: 16, weight: .bold))

            monthNavigator

            dayOfWeekHeaders

            calendarGrid

            legendRow

            if let day = selectedDay {
                selectedDayDetail(day)
            }
        }
        .padding(16)
        .background(AppColors.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Month Navigator

    private var monthNavigator: some View {
        HStack {
            Button { previousMonth() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Menu {
                ForEach(availableMonths, id: \.self) { month in
                    Button(monthYearString(for: month)) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            displayedMonth = month
                            selectedDay = nil
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(monthYearString(for: displayedMonth))
                        .font(.system(size: 15, weight: .bold))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()

            Spacer()

            Button { nextMonth() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
            .disabled(isCurrentMonth)
            .opacity(isCurrentMonth ? 0.3 : 1)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Day Headers

    private var dayOfWeekHeaders: some View {
        HStack(spacing: cellSpacing) {
            ForEach(dayHeaders, id: \.self) { day in
                Text(day)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let weeks = buildMonthWeeks()

        return VStack(spacing: cellSpacing) {
            ForEach(0..<weeks.count, id: \.self) { weekIndex in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let day = weeks[weekIndex][dayIndex] {
                            dayCellView(for: day)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: cellHeight)
                        }
                    }
                }
            }
        }
    }

    private func dayCellView(for day: CalendarDay) -> some View {
        let isSelected = selectedDay?.dateKey == day.dateKey
        let isToday = calendar.isDateInToday(day.date)
        let dayNumber = calendar.component(.day, from: day.date)

        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(colorForLevel(day.level))

            Text("\(dayNumber)")
                .font(.system(size: 14, weight: day.level > 0 ? .bold : .regular))
                .foregroundStyle(day.level >= 3 ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cellHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected ? AppColors.accentBlue :
                    isToday ? AppColors.accentBlue.opacity(0.5) :
                    day.level == 0 ? AppColors.calendarEmptyCellBorder : Color.clear,
                    lineWidth: isSelected || isToday ? 2 : 1
                )
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDay = selectedDay?.dateKey == day.dateKey ? nil : day
            }
        }
    }

    // MARK: - Legend

    private var legendRow: some View {
        HStack(spacing: 6) {
            Text("적음")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)

            ForEach(0...4, id: \.self) { level in
                RoundedRectangle(cornerRadius: 3)
                    .fill(colorForLevel(level))
                    .frame(width: 14, height: 14)
            }

            Text("많음")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Selected Day Detail

    private func selectedDayDetail(_ day: CalendarDay) -> some View {
        let completedBuckets = dailyBucketCounts[day.dateKey] ?? 0
        let bucketEmoji = String(repeating: "🪣", count: min(completedBuckets, 10))

        return VStack(alignment: .leading, spacing: 8) {
            Divider()

            Text(dateService.historyTitle(for: day.dateKey))
                .font(.system(size: 14, weight: .bold))

            if day.totalSeconds == 0 {
                Text("이 날은 집중 기록이 없습니다.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("총 집중 시간")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(TimeFormatter.compactDuration(from: day.totalSeconds))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AppColors.accentBlue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("채운 양동이")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        if completedBuckets > 0 {
                            Text("\(bucketEmoji) \(completedBuckets)개")
                                .font(.system(size: 15, weight: .bold))
                        } else {
                            Text("아직 없음")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .transition(.opacity)
    }

    // MARK: - Navigation

    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            selectedDay = nil
        }
    }

    private func nextMonth() {
        guard !isCurrentMonth else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            selectedDay = nil
        }
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    private var availableMonths: [Date] {
        let comps = calendar.dateComponents([.year, .month], from: Date())
        guard let currentMonthDate = calendar.date(from: comps) else { return [] }

        return (0...11).compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: currentMonthDate)
        }
    }

    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    // MARK: - Data Building

    private func buildMonthWeeks() -> [[CalendarDay?]] {
        let keyFormatter = DateFormatter()
        keyFormatter.dateFormat = "yyyy-MM-dd"
        keyFormatter.locale = Locale(identifier: "ko_KR")

        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps),
              let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count else {
            return []
        }

        let today = calendar.startOfDay(for: Date())

        // Monday-based offset: Mon=0, Tue=1, ..., Sun=6
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let startOffset = firstWeekday == 1 ? 6 : firstWeekday - 2

        let totalCells = startOffset + daysInMonth
        let weekCount = (totalCells + 6) / 7

        var weeks: [[CalendarDay?]] = []

        for week in 0..<weekCount {
            var weekDays: [CalendarDay?] = []
            for dayOfWeek in 0..<7 {
                let dayNumber = week * 7 + dayOfWeek - startOffset + 1

                if dayNumber < 1 || dayNumber > daysInMonth {
                    weekDays.append(nil)
                } else if let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstOfMonth),
                          date <= today {
                    let key = keyFormatter.string(from: date)
                    let seconds = dailyData[key] ?? 0
                    weekDays.append(CalendarDay(date: date, dateKey: key, totalSeconds: seconds))
                } else {
                    weekDays.append(nil)
                }
            }
            weeks.append(weekDays)
        }

        return weeks
    }

    // MARK: - Color

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return AppColors.calendarEmptyCell
        case 1: return AppColors.accentBlue.opacity(0.25)
        case 2: return AppColors.accentBlue.opacity(0.50)
        case 3: return AppColors.accentBlue.opacity(0.75)
        default: return AppColors.accentBlue
        }
    }
}
