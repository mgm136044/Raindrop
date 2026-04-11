import SwiftUI

struct TerrariumView: View {
    let snapshot: GrowthSnapshot
    let placements: [PlantPlacement]
    let bucketContent: AnyView // The existing BucketView

    var body: some View {
        ZStack {
            // Background: terrarium canvas (behind bucket)
            TerrariumCanvasLayer(
                placements: placements,
                phase: snapshot.phase,
                biomeTheme: snapshot.biome.theme
            )

            // Foreground: the bucket itself
            bucketContent
        }
        .drawingGroup()
    }
}
