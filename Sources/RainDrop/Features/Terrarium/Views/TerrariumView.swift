import SwiftUI

struct TerrariumView<Content: View>: View {
    let snapshot: GrowthSnapshot
    let placements: [PlantPlacement]
    var reduceAnimations: Bool = false
    @ViewBuilder let bucketContent: () -> Content

    var body: some View {
        ZStack {
            // Background: terrarium canvas (behind bucket)
            TerrariumCanvasLayer(
                placements: placements,
                phase: snapshot.phase,
                biomeTheme: snapshot.biome.theme,
                reduceAnimations: reduceAnimations
            )
            .drawingGroup()  // Only flatten canvas layer

            // Foreground: the bucket itself
            bucketContent()  // BucketView keeps its own rendering
        }
    }
}
