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

    var hasCustomWaterColor: Bool {
        switch self {
        case .wood, .dentedIron, .platinum: return false
        case .gold, .diamond, .rainbow: return true
        }
    }

    var shapeProvider: AnyBucketSkin {
        switch self {
        case .wood: return AnyBucketSkin(WoodBucket())
        case .dentedIron: return AnyBucketSkin(IronBucket())
        case .platinum: return AnyBucketSkin(PlatinumBucket())
        case .gold: return AnyBucketSkin(GoldBucket())
        case .diamond: return AnyBucketSkin(DiamondBucket())
        case .rainbow: return AnyBucketSkin(RainbowBucket())
        }
    }

    var customDropGradientTop: Color {
        shapeProvider.waterStyle.dropGradientTop
    }

    var customDropGradientBottom: Color {
        shapeProvider.waterStyle.dropGradientBottom
    }
}
