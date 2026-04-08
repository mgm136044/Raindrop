import SwiftUI

enum WaterColorProgression {
    struct WaterColors {
        let top: Color
        let bottom: Color
    }

    static func colors(for totalMinutes: Int) -> WaterColors {
        switch totalMinutes {
        case 0..<300:
            return WaterColors(
                top: Color(red: 0.45, green: 0.75, blue: 0.95),
                bottom: Color(red: 0.20, green: 0.50, blue: 0.85)
            )
        case 300..<1500:
            return WaterColors(
                top: Color(red: 0.30, green: 0.65, blue: 0.90),
                bottom: Color(red: 0.10, green: 0.40, blue: 0.80)
            )
        case 1500..<5000:
            return WaterColors(
                top: Color(red: 0.20, green: 0.60, blue: 0.85),
                bottom: Color(red: 0.05, green: 0.35, blue: 0.75)
            )
        case 5000..<15000:
            return WaterColors(
                top: Color(red: 0.15, green: 0.55, blue: 0.75),
                bottom: Color(red: 0.05, green: 0.30, blue: 0.65)
            )
        default:
            return WaterColors(
                top: Color(red: 0.10, green: 0.40, blue: 0.70),
                bottom: Color(red: 0.03, green: 0.20, blue: 0.55)
            )
        }
    }

}
