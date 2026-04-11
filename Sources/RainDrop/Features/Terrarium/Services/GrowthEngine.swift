import Foundation

@MainActor
final class GrowthEngine {
    static func snapshot(totalMinutes: Int, skin: BucketSkin) -> GrowthSnapshot {
        let level = GrowthCurve.level(for: totalMinutes)
        let progress = GrowthCurve.progress(for: totalMinutes)
        let phase = GrowthSnapshot.GrowthPhase.from(level: level)

        return GrowthSnapshot(
            level: level,
            progressToNext: progress,
            phase: phase,
            totalMinutes: totalMinutes,
            biome: skin.biome
        )
    }
}
