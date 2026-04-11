import SwiftUI

struct TimerSceneView: View {
    @ObservedObject var viewModel: TimerViewModel
    let skin: BucketSkin
    let useCustomWaterColor: Bool
    let dropGradientTop: Color
    let dropGradientBottom: Color
    let placements: [StickerPlacement]
    var waterColorOverride: (top: Color, bottom: Color)?
    var reduceAnimations: Bool = false
    var totalFocusMinutes: Int = 0
    var growthSeed: UInt64 = 0

    @State private var displayProgress: Double = 0

    private var intensity: Double {
        viewModel.isRunning ? viewModel.currentProgress : 0
    }

    private var particlesActive: Bool {
        viewModel.isRunning && !reduceAnimations
    }

    var body: some View {
        ZStack {
            let provider = skin.shapeProvider
            let topFraction = provider.topOpeningFraction
            let bottomFraction = provider.bottomWidthFraction
            let floorFraction = provider.bottomInsetFraction

            let bucketW: CGFloat = 340
            let bucketH: CGFloat = 320
            let cloudW = bucketW * topFraction
            let rainW = bucketW * max(topFraction, bottomFraction) * 0.85

            // Cloud + Rain layer
            ZStack(alignment: .top) {
                CloudView(isVisible: particlesActive, intensity: intensity)
                    .frame(width: cloudW, height: 70)
                    .offset(y: -50)

                RainParticleView(
                    isAnimating: particlesActive,
                    dropGradientTop: dropGradientTop,
                    dropGradientBottom: dropGradientBottom,
                    intensity: max(intensity, 0.15)
                )
                .frame(width: rainW, height: bucketH * floorFraction)
            }
            .frame(width: bucketW, height: 360)
            .allowsHitTesting(false)

            // Bucket + Stickers + Terrarium
            let growthSnapshot = GrowthEngine.snapshot(totalMinutes: totalFocusMinutes, skin: skin)
            let plantPlacements = PlantLayoutEngine.placements(
                biome: skin.biome,
                level: growthSnapshot.level,
                seed: growthSeed
            )
            TerrariumView(
                snapshot: growthSnapshot,
                placements: plantPlacements
            ) {
                BucketWithStickersView(
                    progress: displayProgress,
                    skin: skin,
                    useCustomWaterColor: useCustomWaterColor,
                    intensity: intensity,
                    waterColorOverride: waterColorOverride,
                    placements: placements
                )
            }
            .frame(width: bucketW, height: bucketH)
            .padding(.top, 56)

            // Overflow celebration
            OverflowAnimationView(isActive: viewModel.isOverflowing && !reduceAnimations)
                .frame(width: bucketW, height: bucketH)
                .padding(.top, 56)
                .allowsHitTesting(false)

            // Water splash particles at water surface
            WaterSplashView(
                waterLevel: displayProgress,
                intensity: intensity,
                isActive: particlesActive && displayProgress > 0.05,
                splashColor: dropGradientTop
            )
            .frame(width: bucketW, height: bucketH)
            .padding(.top, 56)
            .allowsHitTesting(false)
        }
        .onChange(of: viewModel.currentProgress) { _,newValue in
            if !viewModel.isDraining && !viewModel.isCycleDraining {
                displayProgress = newValue
            }
        }
        .onChange(of: viewModel.isDraining) { _,draining in
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
        .onChange(of: viewModel.isCycleDraining) { _,draining in
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
