import SwiftUI

struct TimerSceneView: View {
    @ObservedObject var viewModel: TimerViewModel
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    let dropGradientTop: Color
    let dropGradientBottom: Color
    let placements: [StickerPlacement]
    let isDecorating: Bool
    let onAddPlacement: (StickerPlacement) -> Void
    let onRemovePlacement: (UUID) -> Void
    let purchasedItems: Set<String>
    var environmentStage: EnvironmentStage = .barren
    var weatherCondition: WeatherCondition = .cloudy
    var waterColorOverride: (top: Color, bottom: Color)?

    @State private var displayProgress: Double = 0

    private var intensity: Double {
        viewModel.isRunning ? viewModel.currentProgress : 0
    }

    var body: some View {
        ZStack {
            // Environment layer (behind everything)
            EnvironmentView(stage: environmentStage)
                .frame(width: 400, height: 400)
                .allowsHitTesting(false)

            // Weather overlay (ambient, always visible)
            WeatherOverlayView(condition: weatherCondition)
                .frame(width: 400, height: 400)
                .allowsHitTesting(false)

            // Cloud + Rain layer
            ZStack(alignment: .top) {
                CloudView(isVisible: viewModel.isRunning, intensity: intensity)
                    .frame(width: 260, height: 70)
                    .offset(y: -50)

                RainParticleView(
                    isAnimating: viewModel.isRunning,
                    dropGradientTop: dropGradientTop,
                    dropGradientBottom: dropGradientBottom,
                    intensity: max(intensity, 0.15)
                )
                .frame(width: 260, height: 360)
            }
            .frame(width: 340, height: 360)

            // Bucket + Stickers
            BucketWithStickersView(
                progress: displayProgress,
                skin: skin,
                useCustomWaterColor: useCustomWaterColor,
                intensity: intensity,
                waterColorOverride: waterColorOverride,
                placements: placements,
                isDecorating: isDecorating,
                onAddPlacement: onAddPlacement,
                onRemovePlacement: onRemovePlacement,
                purchasedItems: purchasedItems
            )
            .frame(width: 340, height: 320)
            .padding(.top, 56)

            // Overflow celebration
            OverflowAnimationView(isActive: viewModel.isOverflowing)
                .frame(width: 340, height: 320)
                .padding(.top, 56)
                .allowsHitTesting(false)

            // Water splash particles at water surface
            WaterSplashView(
                waterLevel: displayProgress,
                intensity: intensity,
                isActive: viewModel.isRunning && displayProgress > 0.05,
                splashColor: dropGradientTop
            )
            .frame(width: 340, height: 320)
            .padding(.top, 56)
        }
        .onChange(of: viewModel.currentProgress) { newValue in
            if !viewModel.isDraining && !viewModel.isCycleDraining {
                displayProgress = newValue
            }
        }
        .onChange(of: viewModel.isDraining) { draining in
            if draining {
                withAnimation(.easeIn(duration: 1.2)) {
                    displayProgress = 0
                }
                Task {
                    try? await Task.sleep(for: .seconds(1.3))
                    viewModel.finishDraining()
                }
            }
        }
        .onChange(of: viewModel.isCycleDraining) { draining in
            if draining {
                displayProgress = 1.0
                withAnimation(.easeIn(duration: 1.2)) {
                    displayProgress = 0
                }
                Task {
                    try? await Task.sleep(for: .seconds(1.3))
                    viewModel.finishCycleDraining()
                }
            }
        }
    }

}
