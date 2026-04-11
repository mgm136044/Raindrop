import SwiftUI

enum Biome: String, Codable, CaseIterable, Sendable {
    case forest         // Wood bucket
    case industrial     // Iron bucket
    case crystal        // Platinum bucket
    case royal          // Gold bucket
    case ice            // Diamond bucket
    case enchanted      // Rainbow bucket
}

struct BiomeTheme: Sendable {
    let groundGradient: [Color]
    let accentColor: Color
    let particleColor: Color
    let ambientAnimation: AmbientType

    enum AmbientType: Sendable {
        case fireflies(count: Int)
        case steam(opacity: Double)
        case prismRefraction
        case butterflies(count: Int)
        case aurora
        case spores(count: Int)
    }
}

extension Biome {
    var theme: BiomeTheme {
        switch self {
        case .forest:
            BiomeTheme(
                groundGradient: [Color(red: 0.23, green: 0.35, blue: 0.25), Color(red: 0.64, green: 0.69, blue: 0.60)],
                accentColor: Color(red: 0.64, green: 0.69, blue: 0.60),
                particleColor: Color(red: 0.85, green: 0.92, blue: 0.55),
                ambientAnimation: .fireflies(count: 8)
            )
        case .industrial:
            BiomeTheme(
                groundGradient: [Color(red: 0.29, green: 0.31, blue: 0.41), Color(red: 0.60, green: 0.55, blue: 0.60)],
                accentColor: Color(red: 0.60, green: 0.55, blue: 0.60),
                particleColor: Color.white.opacity(0.4),
                ambientAnimation: .steam(opacity: 0.15)
            )
        case .crystal:
            BiomeTheme(
                groundGradient: [Color(red: 0.68, green: 0.91, blue: 0.96), Color(red: 0.79, green: 0.94, blue: 0.97)],
                accentColor: Color(red: 0.56, green: 0.88, blue: 0.94),
                particleColor: Color.white.opacity(0.6),
                ambientAnimation: .prismRefraction
            )
        case .royal:
            BiomeTheme(
                groundGradient: [Color(red: 0.38, green: 0.10, blue: 0.21), Color(red: 1.0, green: 0.84, blue: 0.0)],
                accentColor: Color(red: 1.0, green: 0.84, blue: 0.0),
                particleColor: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5),
                ambientAnimation: .butterflies(count: 5)
            )
        case .ice:
            BiomeTheme(
                groundGradient: [Color(red: 0.0, green: 0.47, blue: 0.71), Color(red: 0.56, green: 0.88, blue: 0.94)],
                accentColor: Color(red: 0.0, green: 0.70, blue: 0.85),
                particleColor: Color.white.opacity(0.5),
                ambientAnimation: .aurora
            )
        case .enchanted:
            BiomeTheme(
                groundGradient: [Color(red: 0.45, green: 0.04, blue: 0.72), Color(red: 0.97, green: 0.15, blue: 0.52)],
                accentColor: Color(red: 0.30, green: 0.79, blue: 0.96),
                particleColor: Color(red: 0.97, green: 0.15, blue: 0.52).opacity(0.4),
                ambientAnimation: .spores(count: 12)
            )
        }
    }
}

extension BucketSkin {
    var biome: Biome {
        switch self {
        case .wood: return .forest
        case .dentedIron: return .industrial
        case .platinum: return .crystal
        case .gold: return .royal
        case .diamond: return .ice
        case .rainbow: return .enchanted
        }
    }
}
