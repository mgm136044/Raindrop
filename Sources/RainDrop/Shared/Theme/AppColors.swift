import SwiftUI
import AppKit

enum AppColors {
    // MARK: - Backgrounds

    static var backgroundGradientTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1.0)
                : NSColor(red: 0.96, green: 0.98, blue: 0.99, alpha: 1.0)
        })
    }

    static var backgroundGradientBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1.0)
                : NSColor(red: 0.88, green: 0.94, blue: 0.98, alpha: 1.0)
        })
    }

    // MARK: - Panels

    static var panelBackground: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.14, green: 0.16, blue: 0.22, alpha: 0.85)
                : NSColor(white: 1.0, alpha: 0.82)
        })
    }

    static var rightPanelGradientTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.12, green: 0.15, blue: 0.22, alpha: 0.95)
                : NSColor(white: 1.0, alpha: 0.95)
        })
    }

    static var rightPanelGradientBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.10, green: 0.16, blue: 0.26, alpha: 1.0)
                : NSColor(red: 0.83, green: 0.93, blue: 0.99, alpha: 1.0)
        })
    }

    // MARK: - Text

    static var primaryText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.92, green: 0.94, blue: 0.97, alpha: 1.0)
                : NSColor(red: 0.08, green: 0.18, blue: 0.31, alpha: 1.0)
        })
    }

    static var titleText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.85, green: 0.90, blue: 0.98, alpha: 1.0)
                : NSColor(red: 0.10, green: 0.20, blue: 0.33, alpha: 1.0)
        })
    }

    static var subtitleText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.55, green: 0.62, blue: 0.72, alpha: 1.0)
                : NSColor(red: 0.16, green: 0.34, blue: 0.55, alpha: 1.0)
        })
    }

    static var rightPanelText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.70, green: 0.80, blue: 0.92, alpha: 1.0)
                : NSColor(red: 0.13, green: 0.28, blue: 0.46, alpha: 1.0)
        })
    }

    static var progressText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.50, green: 0.75, blue: 0.95, alpha: 1.0)
                : NSColor(red: 0.10, green: 0.43, blue: 0.68, alpha: 1.0)
        })
    }

    // MARK: - Accent & Buttons

    static var accentBlue: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.25, green: 0.60, blue: 0.95, alpha: 1.0)
                : NSColor(red: 0.12, green: 0.55, blue: 0.88, alpha: 1.0)
        })
    }

    static var buttonTint: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.22, green: 0.55, blue: 0.88, alpha: 1.0)
                : NSColor(red: 0.14, green: 0.45, blue: 0.75, alpha: 1.0)
        })
    }

    static var startButton: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.20, green: 0.58, blue: 0.92, alpha: 1.0)
                : NSColor(red: 0.12, green: 0.55, blue: 0.88, alpha: 1.0)
        })
    }

    static var pauseButton: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.35, green: 0.55, blue: 0.78, alpha: 1.0)
                : NSColor(red: 0.28, green: 0.50, blue: 0.72, alpha: 1.0)
        })
    }

    static var stopButton: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.90, green: 0.45, blue: 0.32, alpha: 1.0)
                : NSColor(red: 0.86, green: 0.42, blue: 0.28, alpha: 1.0)
        })
    }

    // MARK: - Water

    static var waterGradientTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.30, green: 0.65, blue: 0.90, alpha: 1.0)
                : NSColor(red: 0.39, green: 0.79, blue: 0.97, alpha: 1.0)
        })
    }

    static var waterGradientBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.10, green: 0.35, blue: 0.75, alpha: 1.0)
                : NSColor(red: 0.14, green: 0.48, blue: 0.91, alpha: 1.0)
        })
    }

    static var dropGradientTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.50, green: 0.78, blue: 1.0, alpha: 1.0)
                : NSColor(red: 0.65, green: 0.89, blue: 1.0, alpha: 1.0)
        })
    }

    static var dropGradientBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.12, green: 0.45, blue: 0.85, alpha: 1.0)
                : NSColor(red: 0.18, green: 0.58, blue: 0.95, alpha: 1.0)
        })
    }

    // MARK: - Completion Banner & History

    static var bannerTitle: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.55, green: 0.80, blue: 1.0, alpha: 1.0)
                : NSColor(red: 0.05, green: 0.34, blue: 0.57, alpha: 1.0)
        })
    }

    static var historyHeaderBackground: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 0.85)
                : NSColor(white: 1.0, alpha: 0.70)
        })
    }

    static var historySessionTime: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.45, green: 0.72, blue: 0.95, alpha: 1.0)
                : NSColor(red: 0.10, green: 0.39, blue: 0.62, alpha: 1.0)
        })
    }

    static var historyIcon: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.30, green: 0.60, blue: 0.88, alpha: 1.0)
                : NSColor(red: 0.18, green: 0.52, blue: 0.82, alpha: 1.0)
        })
    }

    // MARK: - Calendar Heatmap

    static var calendarEmptyCell: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1.0)
                : NSColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0)
        })
    }

    static var calendarEmptyCellBorder: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 0.08)
                : NSColor(white: 0.0, alpha: 0.12)
        })
    }

}

// MARK: - SwiftUI Color Accessors (for BucketSkin)

extension AppColors {
    static var waterGradientTopColor: Color { waterGradientTop }
    static var waterGradientBottomColor: Color { waterGradientBottom }
    static var dropGradientTopColor: Color { dropGradientTop }
    static var dropGradientBottomColor: Color { dropGradientBottom }

    // MARK: - Sky Gradient (progress-based)

    static var skyDawnTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.18, green: 0.14, blue: 0.25, alpha: 1.0)
                : NSColor(red: 0.98, green: 0.92, blue: 0.85, alpha: 1.0)
        })
    }

    static var skyDawnBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.22, green: 0.16, blue: 0.12, alpha: 1.0)
                : NSColor(red: 0.95, green: 0.88, blue: 0.78, alpha: 1.0)
        })
    }

    static var skyGatheringTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.12, green: 0.14, blue: 0.22, alpha: 1.0)
                : NSColor(red: 0.82, green: 0.88, blue: 0.94, alpha: 1.0)
        })
    }

    static var skyGatheringBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.10, green: 0.12, blue: 0.20, alpha: 1.0)
                : NSColor(red: 0.78, green: 0.85, blue: 0.92, alpha: 1.0)
        })
    }

    static var skyStormTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.08, green: 0.10, blue: 0.18, alpha: 1.0)
                : NSColor(red: 0.65, green: 0.72, blue: 0.82, alpha: 1.0)
        })
    }

    static var skyStormBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.06, green: 0.08, blue: 0.15, alpha: 1.0)
                : NSColor(red: 0.60, green: 0.68, blue: 0.78, alpha: 1.0)
        })
    }

    static var skyClearingTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.20, green: 0.18, blue: 0.10, alpha: 1.0)
                : NSColor(red: 1.0, green: 0.95, blue: 0.82, alpha: 1.0)
        })
    }

    static var skyClearingBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.15, green: 0.12, blue: 0.08, alpha: 1.0)
                : NSColor(red: 0.98, green: 0.90, blue: 0.72, alpha: 1.0)
        })
    }

    static var cloudColor: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1.0, alpha: 1.0)
                : NSColor(red: 0.55, green: 0.62, blue: 0.72, alpha: 1.0)
        })
    }
}
