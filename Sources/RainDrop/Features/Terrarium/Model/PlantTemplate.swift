import SwiftUI

enum PlantType: String, Sendable, CaseIterable {
    case moss
    case sprout
    case smallFlower
    case tallFlower
    case fern
    case mushroom
    case bush
    case smallTree
    case vine
    case glowPlant
}

struct PlantTemplate: Sendable {
    let type: PlantType
    let appearsAtLevel: Int
    let baseScale: CGFloat      // 0.3 - 1.0
    let color: Color
    let glows: Bool
}

struct PlantPlacement: Sendable {
    let template: PlantTemplate
    let position: CGPoint       // Normalized 0-1 relative to terrarium
    let scale: CGFloat          // Final scale after variation
    let rotation: Double        // Radians
    let zIndex: Double
}
