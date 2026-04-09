import SwiftUI
import AppKit

struct SkyBackgroundView: View {
    let progress: Double
    let isRunning: Bool
    let isOverflowing: Bool
    var backgroundTheme: BackgroundTheme = .defaultTheme

    @State private var currentTop: Color = AppColors.background
    @State private var currentBottom: Color = AppColors.background

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

    private var effectiveTop: Color {
        if !isRunning { return backgroundTheme.idleTop }
        if backgroundTheme == .defaultTheme { return skyTop }
        return blend(skyTop, backgroundTheme.idleTop, t: 0.3)
    }

    private var effectiveBottom: Color {
        if !isRunning { return backgroundTheme.idleBottom }
        if backgroundTheme == .defaultTheme { return skyBottom }
        return blend(skyBottom, backgroundTheme.idleBottom, t: 0.3)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [currentTop, currentBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if backgroundTheme == .deepOcean {
                DeepOceanParticleView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 2.0), value: currentTop)
        .animation(.easeInOut(duration: 2.0), value: currentBottom)
        .animation(.easeInOut(duration: 1.5), value: isOverflowing)
        .animation(.easeInOut(duration: 1.0), value: isRunning)
        .animation(.easeInOut(duration: 1.5), value: backgroundTheme)
        .onAppear {
            currentTop = effectiveTop
            currentBottom = effectiveBottom
        }
        .onChange(of: progress) { _ in
            currentTop = effectiveTop
            currentBottom = effectiveBottom
        }
        .onChange(of: isRunning) { _ in
            currentTop = effectiveTop
            currentBottom = effectiveBottom
        }
        .onChange(of: isOverflowing) { _ in
            currentTop = effectiveTop
            currentBottom = effectiveBottom
        }
        .onChange(of: backgroundTheme) { _ in
            currentTop = effectiveTop
            currentBottom = effectiveBottom
        }
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

// MARK: - 깊은 바다 배경 거품 파티클

private struct DeepOceanParticleView: View {
    @State private var particles: [OceanBubble] = []
    @State private var tick: Int = 0

    private let bubbleCount = 15

    var body: some View {
        Canvas { context, size in
            for bubble in particles {
                let x = bubble.x * size.width
                let y = bubble.y * size.height
                let r = bubble.radius

                let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                context.fill(
                    Circle().path(in: rect),
                    with: .color(.white.opacity(bubble.opacity))
                )

                let hlRect = CGRect(x: x - r * 0.3, y: y - r * 0.3, width: r * 0.6, height: r * 0.6)
                context.fill(
                    Circle().path(in: hlRect),
                    with: .color(.white.opacity(bubble.opacity * 0.5))
                )
            }
        }
        .onAppear {
            initBubbles()
            startTimer()
        }
    }

    private func initBubbles() {
        particles = (0..<bubbleCount).map { _ in
            OceanBubble(
                x: Double.random(in: 0.05...0.95),
                y: Double.random(in: 0.0...1.0),
                speed: Double.random(in: 0.001...0.004),
                radius: Double.random(in: 3.0...8.0),
                opacity: Double.random(in: 0.15...0.35),
                drift: Double.random(in: -0.0004...0.0004)
            )
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0 / 15.0, repeats: true) { _ in
            Task { @MainActor in
                updateBubbles()
            }
        }
    }

    private func updateBubbles() {
        var updated = particles
        for i in updated.indices {
            updated[i].y -= updated[i].speed
            updated[i].x += updated[i].drift

            if updated[i].y < -0.05 || updated[i].x < -0.05 || updated[i].x > 1.05 {
                updated[i] = OceanBubble(
                    x: Double.random(in: 0.05...0.95),
                    y: 1.05,
                    speed: Double.random(in: 0.001...0.004),
                    radius: Double.random(in: 2.0...5.0),
                    opacity: Double.random(in: 0.06...0.18),
                    drift: Double.random(in: -0.0004...0.0004)
                )
            }
        }
        particles = updated
    }
}

private struct OceanBubble {
    var x: Double
    var y: Double
    var speed: Double
    var radius: Double
    var opacity: Double
    var drift: Double
}
