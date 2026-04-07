import SwiftUI
import AppKit

struct SkyBackgroundView: View {
    let progress: Double
    let isRunning: Bool
    let isOverflowing: Bool

    private var skyTop: Color {
        if isOverflowing {
            return AppColors.skyClearingTop
        }
        let p = min(max(progress, 0), 1)
        if p < 0.2 {
            return blend(AppColors.skyDawnTop, AppColors.skyGatheringTop, t: p / 0.2)
        } else if p < 0.5 {
            return blend(AppColors.skyGatheringTop, AppColors.skyStormTop, t: (p - 0.2) / 0.3)
        } else {
            return AppColors.skyStormTop
        }
    }

    private var skyBottom: Color {
        if isOverflowing {
            return AppColors.skyClearingBottom
        }
        let p = min(max(progress, 0), 1)
        if p < 0.2 {
            return blend(AppColors.skyDawnBottom, AppColors.skyGatheringBottom, t: p / 0.2)
        } else if p < 0.5 {
            return blend(AppColors.skyGatheringBottom, AppColors.skyStormBottom, t: (p - 0.2) / 0.3)
        } else {
            return AppColors.skyStormBottom
        }
    }

    var body: some View {
        LinearGradient(
            colors: [
                isRunning ? skyTop : AppColors.backgroundGradientTop,
                isRunning ? skyBottom : AppColors.backgroundGradientBottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 2.0), value: progress)
        .animation(.easeInOut(duration: 1.5), value: isOverflowing)
        .animation(.easeInOut(duration: 1.0), value: isRunning)
    }

    private func blend(_ a: Color, _ b: Color, t: Double) -> Color {
        let clamped = min(max(t, 0), 1)
        let nsA = NSColor(a).usingColorSpace(.deviceRGB) ?? NSColor(a)
        let nsB = NSColor(b).usingColorSpace(.deviceRGB) ?? NSColor(b)
        var rA: CGFloat = 0, gA: CGFloat = 0, bA: CGFloat = 0, aA: CGFloat = 0
        var rB: CGFloat = 0, gB: CGFloat = 0, bB: CGFloat = 0, aB: CGFloat = 0
        nsA.getRed(&rA, green: &gA, blue: &bA, alpha: &aA)
        nsB.getRed(&rB, green: &gB, blue: &bB, alpha: &aB)
        return Color(
            red: rA + (rB - rA) * clamped,
            green: gA + (gB - gA) * clamped,
            blue: bA + (bB - bA) * clamped
        )
    }
}
