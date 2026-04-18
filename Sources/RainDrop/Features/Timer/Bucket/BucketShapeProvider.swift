import SwiftUI

// MARK: - Render Mode

enum BucketRenderMode: Sendable {
    case full
    case mini
}

// MARK: - Color Palette

struct BucketColorPalette: Sendable {
    let fill: Color
    let stroke: Color
    let band: Color
    let accent: Color
}

// MARK: - Water Style

struct WaterStyle: Sendable {
    let gradientTop: Color
    let gradientBottom: Color
    let dropGradientTop: Color
    let dropGradientBottom: Color
    let surfaceReflectionOpacity: Double

    static let defaultBlue = WaterStyle(
        gradientTop: AppColors.waterGradientTopColor,
        gradientBottom: AppColors.waterGradientBottomColor,
        dropGradientTop: AppColors.dropGradientTopColor,
        dropGradientBottom: AppColors.dropGradientBottomColor,
        surfaceReflectionOpacity: 0.15
    )
}

// MARK: - Animation Config

enum IdleAnimationType: Sendable {
    case breathe(scale: CGFloat, duration: Double)
    case scanHighlight(duration: Double)
    case facetShimmer
    case hueRotation(duration: Double)
}

struct BucketAnimationConfig: Sendable {
    let idleAnimation: IdleAnimationType?
    let waveIntensityMultiplier: Double

    static let none = BucketAnimationConfig(idleAnimation: nil, waveIntensityMultiplier: 1.0)
}

// MARK: - Provider Protocol

protocol BucketShapeProvider: Sendable {
    associatedtype OverlayContent: View

    nonisolated func bodyPath(in rect: CGRect, mode: BucketRenderMode) -> Path
    nonisolated func rimPath(in rect: CGRect) -> Path
    nonisolated func bandPaths(in rect: CGRect) -> [Path]

    @ViewBuilder func overlay(in rect: CGRect, mode: BucketRenderMode) -> OverlayContent

    var colorPalette: BucketColorPalette { get }
    var waterStyle: WaterStyle { get }
    var animationConfig: BucketAnimationConfig { get }

    /// Fraction of bucket width that is the top opening (0.0-1.0)
    var topOpeningFraction: Double { get }

    /// Fraction of bucket width at the bottom (0.0-1.0)
    var bottomWidthFraction: Double { get }

    /// Scale factor for water mask relative to body shape
    var waterMaskScale: Double { get }

    /// Maximum fill height as fraction of bucket height (0.0-1.0)
    var maxFillHeight: Double { get }

    /// Bottom offset as fraction of bucket height (0.0-1.0) — where rain lands
    var bottomInsetFraction: Double { get }
}

// MARK: - Type-Erased Wrapper

struct AnyBucketSkin: BucketShapeProvider, @unchecked Sendable {
    private let _bodyPath: @Sendable (CGRect, BucketRenderMode) -> Path
    private let _rimPath: @Sendable (CGRect) -> Path
    private let _bandPaths: @Sendable (CGRect) -> [Path]
    private let _overlay: @Sendable (CGRect, BucketRenderMode) -> AnyView
    private let _colorPalette: BucketColorPalette
    private let _waterStyle: WaterStyle
    private let _animationConfig: BucketAnimationConfig
    private let _topOpeningFraction: Double
    private let _bottomWidthFraction: Double
    private let _waterMaskScale: Double
    private let _maxFillHeight: Double
    private let _bottomInsetFraction: Double

    init<S: BucketShapeProvider>(_ skin: S) {
        _bodyPath = { skin.bodyPath(in: $0, mode: $1) }
        _rimPath = { skin.rimPath(in: $0) }
        _bandPaths = { skin.bandPaths(in: $0) }
        _overlay = { AnyView(skin.overlay(in: $0, mode: $1)) }
        _colorPalette = skin.colorPalette
        _waterStyle = skin.waterStyle
        _animationConfig = skin.animationConfig
        _topOpeningFraction = skin.topOpeningFraction
        _bottomWidthFraction = skin.bottomWidthFraction
        _waterMaskScale = skin.waterMaskScale
        _maxFillHeight = skin.maxFillHeight
        _bottomInsetFraction = skin.bottomInsetFraction
    }

    nonisolated func bodyPath(in rect: CGRect, mode: BucketRenderMode) -> Path { _bodyPath(rect, mode) }
    nonisolated func rimPath(in rect: CGRect) -> Path { _rimPath(rect) }
    nonisolated func bandPaths(in rect: CGRect) -> [Path] { _bandPaths(rect) }
    func overlay(in rect: CGRect, mode: BucketRenderMode) -> AnyView { _overlay(rect, mode) }

    var colorPalette: BucketColorPalette { _colorPalette }
    var waterStyle: WaterStyle { _waterStyle }
    var animationConfig: BucketAnimationConfig { _animationConfig }
    var topOpeningFraction: Double { _topOpeningFraction }
    var bottomWidthFraction: Double { _bottomWidthFraction }
    var waterMaskScale: Double { _waterMaskScale }
    var maxFillHeight: Double { _maxFillHeight }
    var bottomInsetFraction: Double { _bottomInsetFraction }
}
