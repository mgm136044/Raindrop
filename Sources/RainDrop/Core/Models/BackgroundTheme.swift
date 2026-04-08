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
                    ? NSColor(red: 0.04, green: 0.09, blue: 0.16, alpha: 1)  // #0a1628
                    : NSColor(red: 0.91, green: 0.96, blue: 0.97, alpha: 1)  // #e8f4f8
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
                    ? NSColor(red: 0.05, green: 0.13, blue: 0.22, alpha: 1)  // #0d2137
                    : NSColor(red: 0.82, green: 0.92, blue: 0.96, alpha: 1)  // #d0eaf5
            })
        }
    }

    static func theme(for shopItemID: String?) -> BackgroundTheme {
        guard let id = shopItemID else { return .defaultTheme }
        return allCases.first { $0.shopItemID == id } ?? .defaultTheme
    }
}
