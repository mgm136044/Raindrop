import SwiftUI

struct PlantLayoutEngine: Sendable {
    /// Generate plant placements for a given biome and level
    static func placements(biome: Biome, level: Int, seed: UInt64) -> [PlantPlacement] {
        let templates = Self.templates(for: biome)
        let activeTemplates = templates.filter { $0.appearsAtLevel <= level }

        var rng = SeededRNG(seed: seed)
        var result: [PlantPlacement] = []

        for template in activeTemplates {
            // Growth factor: how developed this plant is (0 at appear level, 1 at +10 levels)
            let growthFactor = min(1.0, Double(level - template.appearsAtLevel) / 10.0)
            let scale = template.baseScale * (0.5 + 0.5 * growthFactor)

            // Position: distributed along bottom arc beneath bucket
            let baseX = Double.random(in: 0.1...0.9, using: &rng)
            let baseY = Double.random(in: 0.75...0.95, using: &rng)
            let rotation = Double.random(in: -0.15...0.15, using: &rng)

            result.append(PlantPlacement(
                template: template,
                position: CGPoint(x: baseX, y: baseY),
                scale: scale,
                rotation: rotation,
                zIndex: baseY * 10 // Further back = lower z
            ))
        }

        return result.sorted { $0.zIndex < $1.zIndex }
    }

    /// Define plant templates per biome
    static func templates(for biome: Biome) -> [PlantTemplate] {
        switch biome {
        case .forest:
            return [
                PlantTemplate(type: .moss, appearsAtLevel: 1, baseScale: 0.4, color: Color(red: 0.23, green: 0.35, blue: 0.25), glows: false),
                PlantTemplate(type: .sprout, appearsAtLevel: 3, baseScale: 0.35, color: Color(red: 0.40, green: 0.55, blue: 0.30), glows: false),
                PlantTemplate(type: .mushroom, appearsAtLevel: 5, baseScale: 0.45, color: Color(red: 0.72, green: 0.55, blue: 0.40), glows: false),
                PlantTemplate(type: .fern, appearsAtLevel: 8, baseScale: 0.5, color: Color(red: 0.30, green: 0.50, blue: 0.28), glows: false),
                PlantTemplate(type: .smallFlower, appearsAtLevel: 12, baseScale: 0.4, color: Color(red: 0.85, green: 0.70, blue: 0.40), glows: false),
                PlantTemplate(type: .bush, appearsAtLevel: 18, baseScale: 0.6, color: Color(red: 0.25, green: 0.45, blue: 0.22), glows: false),
                PlantTemplate(type: .tallFlower, appearsAtLevel: 25, baseScale: 0.55, color: Color(red: 0.90, green: 0.40, blue: 0.50), glows: false),
                PlantTemplate(type: .vine, appearsAtLevel: 30, baseScale: 0.5, color: Color(red: 0.20, green: 0.40, blue: 0.20), glows: false),
                PlantTemplate(type: .smallTree, appearsAtLevel: 38, baseScale: 0.8, color: Color(red: 0.28, green: 0.42, blue: 0.25), glows: false),
                PlantTemplate(type: .glowPlant, appearsAtLevel: 45, baseScale: 0.5, color: Color(red: 0.85, green: 0.92, blue: 0.55), glows: true),
            ]
        case .industrial:
            return [
                PlantTemplate(type: .moss, appearsAtLevel: 1, baseScale: 0.35, color: Color(red: 0.45, green: 0.50, blue: 0.45), glows: false),
                PlantTemplate(type: .sprout, appearsAtLevel: 3, baseScale: 0.3, color: Color(red: 0.55, green: 0.60, blue: 0.55), glows: false),
                PlantTemplate(type: .smallFlower, appearsAtLevel: 8, baseScale: 0.4, color: Color(red: 0.60, green: 0.55, blue: 0.60), glows: false),
                PlantTemplate(type: .fern, appearsAtLevel: 12, baseScale: 0.45, color: Color(red: 0.50, green: 0.55, blue: 0.48), glows: false),
                PlantTemplate(type: .bush, appearsAtLevel: 20, baseScale: 0.55, color: Color(red: 0.40, green: 0.48, blue: 0.42), glows: false),
                PlantTemplate(type: .tallFlower, appearsAtLevel: 28, baseScale: 0.5, color: Color(red: 0.78, green: 0.78, blue: 0.80), glows: false),
                PlantTemplate(type: .vine, appearsAtLevel: 35, baseScale: 0.5, color: Color(red: 0.45, green: 0.50, blue: 0.45), glows: false),
                PlantTemplate(type: .smallTree, appearsAtLevel: 40, baseScale: 0.7, color: Color(red: 0.35, green: 0.42, blue: 0.38), glows: false),
                PlantTemplate(type: .glowPlant, appearsAtLevel: 45, baseScale: 0.45, color: Color(red: 0.80, green: 0.85, blue: 0.90), glows: true),
            ]
        case .crystal:
            return [
                PlantTemplate(type: .moss, appearsAtLevel: 1, baseScale: 0.35, color: Color(red: 0.68, green: 0.91, blue: 0.96), glows: false),
                PlantTemplate(type: .sprout, appearsAtLevel: 3, baseScale: 0.35, color: Color(red: 0.56, green: 0.88, blue: 0.94), glows: false),
                PlantTemplate(type: .smallFlower, appearsAtLevel: 8, baseScale: 0.4, color: Color(red: 0.79, green: 0.94, blue: 0.97), glows: true),
                PlantTemplate(type: .fern, appearsAtLevel: 15, baseScale: 0.5, color: Color(red: 0.60, green: 0.85, blue: 0.92), glows: false),
                PlantTemplate(type: .tallFlower, appearsAtLevel: 22, baseScale: 0.5, color: Color.white, glows: true),
                PlantTemplate(type: .bush, appearsAtLevel: 30, baseScale: 0.6, color: Color(red: 0.70, green: 0.90, blue: 0.95), glows: false),
                PlantTemplate(type: .glowPlant, appearsAtLevel: 40, baseScale: 0.55, color: Color.white.opacity(0.9), glows: true),
            ]
        case .royal:
            return [
                PlantTemplate(type: .moss, appearsAtLevel: 1, baseScale: 0.35, color: Color(red: 0.38, green: 0.15, blue: 0.22), glows: false),
                PlantTemplate(type: .sprout, appearsAtLevel: 3, baseScale: 0.35, color: Color(red: 0.50, green: 0.25, blue: 0.18), glows: false),
                PlantTemplate(type: .smallFlower, appearsAtLevel: 8, baseScale: 0.45, color: Color(red: 0.90, green: 0.22, blue: 0.27), glows: false),
                PlantTemplate(type: .tallFlower, appearsAtLevel: 15, baseScale: 0.5, color: Color(red: 1.0, green: 0.84, blue: 0.0), glows: false),
                PlantTemplate(type: .bush, appearsAtLevel: 22, baseScale: 0.55, color: Color(red: 0.45, green: 0.20, blue: 0.25), glows: false),
                PlantTemplate(type: .vine, appearsAtLevel: 30, baseScale: 0.5, color: Color(red: 0.60, green: 0.30, blue: 0.20), glows: false),
                PlantTemplate(type: .smallTree, appearsAtLevel: 38, baseScale: 0.7, color: Color(red: 0.50, green: 0.22, blue: 0.18), glows: false),
                PlantTemplate(type: .glowPlant, appearsAtLevel: 45, baseScale: 0.5, color: Color(red: 1.0, green: 0.84, blue: 0.0), glows: true),
            ]
        case .ice:
            return [
                PlantTemplate(type: .moss, appearsAtLevel: 1, baseScale: 0.35, color: Color(red: 0.75, green: 0.88, blue: 0.95), glows: false),
                PlantTemplate(type: .sprout, appearsAtLevel: 4, baseScale: 0.3, color: Color(red: 0.56, green: 0.88, blue: 0.94), glows: false),
                PlantTemplate(type: .smallFlower, appearsAtLevel: 10, baseScale: 0.4, color: Color.white, glows: true),
                PlantTemplate(type: .fern, appearsAtLevel: 18, baseScale: 0.5, color: Color(red: 0.0, green: 0.70, blue: 0.85), glows: false),
                PlantTemplate(type: .tallFlower, appearsAtLevel: 28, baseScale: 0.5, color: Color(red: 0.60, green: 0.90, blue: 1.0), glows: true),
                PlantTemplate(type: .glowPlant, appearsAtLevel: 42, baseScale: 0.55, color: Color(red: 0.40, green: 0.95, blue: 0.80), glows: true),
            ]
        case .enchanted:
            return [
                PlantTemplate(type: .moss, appearsAtLevel: 1, baseScale: 0.4, color: Color(red: 0.45, green: 0.04, blue: 0.72), glows: true),
                PlantTemplate(type: .sprout, appearsAtLevel: 3, baseScale: 0.35, color: Color(red: 0.30, green: 0.79, blue: 0.96), glows: true),
                PlantTemplate(type: .mushroom, appearsAtLevel: 6, baseScale: 0.45, color: Color(red: 0.97, green: 0.15, blue: 0.52), glows: true),
                PlantTemplate(type: .smallFlower, appearsAtLevel: 10, baseScale: 0.45, color: Color(red: 0.30, green: 0.79, blue: 0.96), glows: true),
                PlantTemplate(type: .fern, appearsAtLevel: 16, baseScale: 0.5, color: Color(red: 0.55, green: 0.20, blue: 0.80), glows: true),
                PlantTemplate(type: .tallFlower, appearsAtLevel: 22, baseScale: 0.55, color: Color(red: 0.97, green: 0.15, blue: 0.52), glows: true),
                PlantTemplate(type: .vine, appearsAtLevel: 30, baseScale: 0.5, color: Color(red: 0.45, green: 0.04, blue: 0.72), glows: true),
                PlantTemplate(type: .bush, appearsAtLevel: 36, baseScale: 0.6, color: Color(red: 0.30, green: 0.60, blue: 0.90), glows: true),
                PlantTemplate(type: .glowPlant, appearsAtLevel: 42, baseScale: 0.55, color: Color(red: 0.97, green: 0.15, blue: 0.52), glows: true),
            ]
        }
    }
}

/// Seeded random number generator for deterministic plant placement
struct SeededRNG: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
}
