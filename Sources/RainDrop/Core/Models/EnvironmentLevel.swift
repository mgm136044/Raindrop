import Foundation

enum EnvironmentStage: Int, Codable, CaseIterable, Sendable {
    case barren = 0
    case grass = 1
    case flowers = 2
    case trees = 3
    case forest = 4
    case lake = 5

    var requiredTotalMinutes: Int {
        switch self {
        case .barren: return 0
        case .grass: return 300
        case .flowers: return 1500
        case .trees: return 5000
        case .forest: return 15000
        case .lake: return 40000
        }
    }

    var displayName: String {
        switch self {
        case .barren: return "맨땅"
        case .grass: return "풀밭"
        case .flowers: return "꽃밭"
        case .trees: return "나무"
        case .forest: return "숲"
        case .lake: return "호수"
        }
    }

    var emoji: String {
        switch self {
        case .barren: return "🏜️"
        case .grass: return "🌱"
        case .flowers: return "🌸"
        case .trees: return "🌳"
        case .forest: return "🌲"
        case .lake: return "🏞️"
        }
    }

    var description: String {
        switch self {
        case .barren: return "집중을 시작하면 세계가 변합니다"
        case .grass: return "작은 풀이 자라기 시작했어요"
        case .flowers: return "꽃들이 피어나고 있어요"
        case .trees: return "나무가 자라고 있어요"
        case .forest: return "울창한 숲이 되었어요"
        case .lake: return "고요한 호수가 생겼어요"
        }
    }

    static func stage(for totalMinutes: Int) -> EnvironmentStage {
        for stage in Self.allCases.reversed() {
            if totalMinutes >= stage.requiredTotalMinutes {
                return stage
            }
        }
        return .barren
    }

    var nextStage: EnvironmentStage? {
        EnvironmentStage(rawValue: rawValue + 1)
    }
}
