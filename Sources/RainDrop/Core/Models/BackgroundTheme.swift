import SwiftUI
import AppKit

enum BackgroundTheme: String, Codable, CaseIterable, Sendable {
    case defaultTheme
    case deepOcean

    var shopItemID: String? {
        switch self {
        case .defaultTheme: return nil
        case .deepOcean: return "bg_deep_ocean"
        }
    }

    var displayName: String {
        switch self {
        case .defaultTheme: return "기본"
        case .deepOcean: return "깊은 바다"
        }
    }

    var description: String {
        switch self {
        case .defaultTheme: return "기본 배경"
        case .deepOcean: return "고요한 심해의 정적"
        }
    }

    /// 타이머 비활성 시 배경 상단 색상
    var idleTop: Color {
        switch self {
        case .defaultTheme:
            return AppColors.background
        case .deepOcean:
            return Color(nsColor: NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    ? NSColor(red: 0.05, green: 0.12, blue: 0.23, alpha: 1)  // #0c1e3a
                    : NSColor(red: 0.88, green: 0.94, blue: 0.97, alpha: 1)  // #e0f0f8
            })
        }
    }

    /// 타이머 비활성 시 배경 하단 색상
    var idleBottom: Color {
        switch self {
        case .defaultTheme:
            return AppColors.background
        case .deepOcean:
            return Color(nsColor: NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    ? NSColor(red: 0.08, green: 0.18, blue: 0.31, alpha: 1)  // #142d4f
                    : NSColor(red: 0.78, green: 0.90, blue: 0.96, alpha: 1)  // #c7e5f5
            })
        }
    }

    static func theme(for shopItemID: String?) -> BackgroundTheme {
        guard let id = shopItemID else { return .defaultTheme }
        return allCases.first { $0.shopItemID == id } ?? .defaultTheme
    }
}
