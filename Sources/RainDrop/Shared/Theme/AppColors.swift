import SwiftUI
import AppKit

enum AppColors {
    // MARK: - Background (Apple Binary: pure black / light gray)

    static var background: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0, green: 0, blue: 0, alpha: 1)           // #000000
                : NSColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)  // #f5f5f7
        })
    }

    // MARK: - Text (Apple Hierarchy)

    static var primaryText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 1)                             // #ffffff
                : NSColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)  // #1d1d1f
        })
    }

    static var secondaryText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 0.60)
                : NSColor(white: 0, alpha: 0.48)
        })
    }

    static var tertiaryText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 0.35)
                : NSColor(white: 0, alpha: 0.25)
        })
    }

    // MARK: - Accent (Single Color: Apple Blue)

    static var accent: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.16, green: 0.59, blue: 1, alpha: 1)     // #2997ff
                : NSColor(red: 0, green: 0.44, blue: 0.89, alpha: 1)     // #0071e3
        })
    }

    static var danger: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 1, green: 0.27, blue: 0.23, alpha: 1)     // #ff453a
                : NSColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)     // #ff3b30
        })
    }

    // MARK: - Surface

    static var surface: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)  // #1c1c1e
                : NSColor(white: 1, alpha: 1)                             // #ffffff
        })
    }

    // MARK: - Legacy Aliases (backward compatibility)

    static var backgroundGradientTop: Color { background }
    static var backgroundGradientBottom: Color { background }
    static var titleText: Color { primaryText }
    static var subtitleText: Color { secondaryText }
    static var rightPanelText: Color { secondaryText }
    static var progressText: Color { accent }
    static var accentBlue: Color { accent }
    static var buttonTint: Color { accent }
    static var startButton: Color { accent }
    static var pauseButton: Color { accent }
    static var stopButton: Color { danger }
    static var bannerTitle: Color { accent }
    static var panelBackground: Color { surface }
    static var rightPanelGradientTop: Color { background }
    static var rightPanelGradientBottom: Color { background }
    static var historyHeaderBackground: Color { surface }
    static var historySessionTime: Color { accent }
    static var historyIcon: Color { accent }
    static var calendarEmptyCell: Color { surface }
    static var calendarEmptyCellBorder: Color { tertiaryText }

    // MARK: - Water (Natural colors preserved)

    static var waterGradientTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.30, green: 0.65, blue: 0.90, alpha: 1)
                : NSColor(red: 0.39, green: 0.79, blue: 0.97, alpha: 1)
        })
    }

    static var waterGradientBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.10, green: 0.35, blue: 0.75, alpha: 1)
                : NSColor(red: 0.14, green: 0.48, blue: 0.91, alpha: 1)
        })
    }

    static var dropGradientTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.50, green: 0.78, blue: 1.0, alpha: 1)
                : NSColor(red: 0.65, green: 0.89, blue: 1.0, alpha: 1)
        })
    }

    static var dropGradientBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.12, green: 0.45, blue: 0.85, alpha: 1)
                : NSColor(red: 0.18, green: 0.58, blue: 0.95, alpha: 1)
        })
    }

    static var cloudColor: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 1)
                : NSColor(white: 0.4, alpha: 1)
        })
    }
}

// MARK: - Accessors

extension AppColors {
    static var waterGradientTopColor: Color { waterGradientTop }
    static var waterGradientBottomColor: Color { waterGradientBottom }
    static var dropGradientTopColor: Color { dropGradientTop }
    static var dropGradientBottomColor: Color { dropGradientBottom }

    // MARK: - Sky Gradients (session progress)

    static var skyDawnTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.08, green: 0.06, blue: 0.12, alpha: 1)
                : NSColor(red: 0.96, green: 0.92, blue: 0.88, alpha: 1)
        })
    }

    static var skyDawnBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.06, green: 0.04, blue: 0.04, alpha: 1)
                : NSColor(red: 0.94, green: 0.90, blue: 0.84, alpha: 1)
        })
    }

    static var skyGatheringTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1)
                : NSColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 1)
        })
    }

    static var skyGatheringBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.02, green: 0.02, blue: 0.06, alpha: 1)
                : NSColor(red: 0.82, green: 0.86, blue: 0.90, alpha: 1)
        })
    }

    static var skyStormTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.02, green: 0.02, blue: 0.04, alpha: 1)
                : NSColor(red: 0.70, green: 0.74, blue: 0.80, alpha: 1)
        })
    }

    static var skyStormBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0, green: 0, blue: 0.02, alpha: 1)
                : NSColor(red: 0.65, green: 0.70, blue: 0.76, alpha: 1)
        })
    }

    static var skyClearingTop: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.10, green: 0.08, blue: 0.04, alpha: 1)
                : NSColor(red: 1, green: 0.96, blue: 0.88, alpha: 1)
        })
    }

    static var skyClearingBottom: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.06, green: 0.04, blue: 0.02, alpha: 1)
                : NSColor(red: 0.98, green: 0.92, blue: 0.80, alpha: 1)
        })
    }
}
