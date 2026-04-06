import SwiftUI

enum BucketSkin: String, Codable, CaseIterable, Sendable {
    case wood
    case dentedIron
    case platinum
    case gold
    case diamond
    case rainbow

    var requiredBuckets: Int {
        switch self {
        case .wood: return 0
        case .dentedIron: return 50
        case .platinum: return 150
        case .gold: return 250
        case .diamond: return 1700
        case .rainbow: return 5000
        }
    }

    func isUnlocked(totalBuckets: Int) -> Bool {
        totalBuckets >= requiredBuckets
    }

    var displayName: String {
        switch self {
        case .wood: return "나무 양동이"
        case .dentedIron: return "찌그러진 철 양동이"
        case .platinum: return "백금 양동이"
        case .gold: return "금 양동이"
        case .diamond: return "다이아 양동이"
        case .rainbow: return "무지개 양동이"
        }
    }

    var materialDescription: String {
        switch self {
        case .wood: return "오래된 참나무로 만든 소박한 양동이"
        case .dentedIron: return "사용감 있는 철로 만든 튼튼한 양동이"
        case .platinum: return "광택 나는 백금으로 제작된 고급 양동이"
        case .gold: return "순금으로 도금된 화려한 양동이"
        case .diamond: return "다이아몬드 결정으로 빛나는 보석 양동이"
        case .rainbow: return "일곱 빛깔 무지개가 흐르는 전설의 양동이"
        }
    }

    var bucketFill: Color {
        switch self {
        case .wood: return Color(red: 0.55, green: 0.35, blue: 0.18, opacity: 0.72)
        case .dentedIron: return Color(red: 0.35, green: 0.38, blue: 0.42, opacity: 0.72)
        case .platinum: return Color(red: 0.85, green: 0.87, blue: 0.90, opacity: 0.72)
        case .gold: return Color(red: 0.85, green: 0.68, blue: 0.20, opacity: 0.72)
        case .diamond: return Color(red: 0.70, green: 0.85, blue: 0.95, opacity: 0.72)
        case .rainbow: return Color(red: 0.90, green: 0.80, blue: 0.95, opacity: 0.72)
        }
    }

    var bucketStroke: Color {
        switch self {
        case .wood: return Color(red: 0.40, green: 0.25, blue: 0.12)
        case .dentedIron: return Color(red: 0.45, green: 0.48, blue: 0.52)
        case .platinum: return Color(red: 0.75, green: 0.78, blue: 0.82)
        case .gold: return Color(red: 0.75, green: 0.58, blue: 0.10)
        case .diamond: return Color(red: 0.55, green: 0.75, blue: 0.90)
        case .rainbow: return Color(red: 0.70, green: 0.50, blue: 0.80)
        }
    }

    var bucketHandle: Color {
        switch self {
        case .wood: return Color(red: 0.35, green: 0.22, blue: 0.10)
        case .dentedIron: return Color(red: 0.50, green: 0.52, blue: 0.55)
        case .platinum: return Color(red: 0.80, green: 0.82, blue: 0.85)
        case .gold: return Color(red: 0.80, green: 0.62, blue: 0.15)
        case .diamond: return Color(red: 0.60, green: 0.78, blue: 0.92)
        case .rainbow: return Color(red: 0.75, green: 0.55, blue: 0.85)
        }
    }

    var bandColor: Color {
        switch self {
        case .wood: return Color(red: 0.30, green: 0.18, blue: 0.08)
        case .dentedIron: return bucketStroke.opacity(0.4)
        case .platinum: return bucketStroke.opacity(0.5)
        case .gold: return Color(red: 0.90, green: 0.75, blue: 0.25)
        case .diamond: return Color(red: 0.65, green: 0.85, blue: 1.0)
        case .rainbow: return Color(red: 0.80, green: 0.60, blue: 0.90)
        }
    }

    var hasCustomWaterColor: Bool {
        switch self {
        case .wood, .dentedIron, .platinum: return false
        case .gold, .diamond, .rainbow: return true
        }
    }

    var customWaterGradientTop: Color {
        switch self {
        case .gold: return Color(red: 1.0, green: 0.85, blue: 0.35)
        case .diamond: return Color(red: 0.70, green: 0.90, blue: 1.0)
        case .rainbow: return Color(red: 1.0, green: 0.60, blue: 0.60)
        default: return AppColors.waterGradientTopColor
        }
    }

    var customWaterGradientBottom: Color {
        switch self {
        case .gold: return Color(red: 0.85, green: 0.60, blue: 0.05)
        case .diamond: return Color(red: 0.40, green: 0.65, blue: 0.95)
        case .rainbow: return Color(red: 0.50, green: 0.30, blue: 0.90)
        default: return AppColors.waterGradientBottomColor
        }
    }

    var customDropGradientTop: Color {
        switch self {
        case .gold: return Color(red: 1.0, green: 0.90, blue: 0.50)
        case .diamond: return Color(red: 0.80, green: 0.95, blue: 1.0)
        case .rainbow: return Color(red: 1.0, green: 0.70, blue: 0.70)
        default: return AppColors.dropGradientTopColor
        }
    }

    var customDropGradientBottom: Color {
        switch self {
        case .gold: return Color(red: 0.90, green: 0.65, blue: 0.10)
        case .diamond: return Color(red: 0.50, green: 0.70, blue: 1.0)
        case .rainbow: return Color(red: 0.60, green: 0.35, blue: 0.95)
        default: return AppColors.dropGradientBottomColor
        }
    }
}
