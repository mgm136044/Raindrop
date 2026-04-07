import Foundation

struct AppSettings: Codable, Equatable, Sendable {
    var sessionGoalMinutes: Int = 25
    var focusCheckEnabled: Bool = false
    var focusCheckIntervalMinutes: Int = 5
    var infinityModeEnabled: Bool = false
    var selectedSkin: BucketSkin = .wood
    var useCustomWaterColor: Bool = false
    var whiteNoiseEnabled: Bool = false
    var whiteNoiseVolume: Double = 0.5
    var hasSeenOnboarding: Bool = false
    var waterColorEvolution: Bool = false

    var sessionGoalSeconds: Int { sessionGoalMinutes * 60 }

    static let `default` = AppSettings()
    static let storageFilename = "app_settings.json"

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .sessionGoalMinutes) ?? 25
        focusCheckEnabled = try container.decodeIfPresent(Bool.self, forKey: .focusCheckEnabled) ?? false
        focusCheckIntervalMinutes = try container.decodeIfPresent(Int.self, forKey: .focusCheckIntervalMinutes) ?? 5
        infinityModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .infinityModeEnabled) ?? false
        selectedSkin = try container.decodeIfPresent(BucketSkin.self, forKey: .selectedSkin) ?? .wood
        useCustomWaterColor = try container.decodeIfPresent(Bool.self, forKey: .useCustomWaterColor) ?? false
        whiteNoiseEnabled = try container.decodeIfPresent(Bool.self, forKey: .whiteNoiseEnabled) ?? false
        whiteNoiseVolume = try container.decodeIfPresent(Double.self, forKey: .whiteNoiseVolume) ?? 0.5
        hasSeenOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasSeenOnboarding) ?? false
        waterColorEvolution = try container.decodeIfPresent(Bool.self, forKey: .waterColorEvolution) ?? false
    }

    init(
        sessionGoalMinutes: Int = 25,
        focusCheckEnabled: Bool = false,
        focusCheckIntervalMinutes: Int = 5,
        infinityModeEnabled: Bool = false,
        selectedSkin: BucketSkin = .wood,
        useCustomWaterColor: Bool = false,
        whiteNoiseEnabled: Bool = false,
        whiteNoiseVolume: Double = 0.5,
        hasSeenOnboarding: Bool = false,
        waterColorEvolution: Bool = false
    ) {
        self.sessionGoalMinutes = sessionGoalMinutes
        self.focusCheckEnabled = focusCheckEnabled
        self.focusCheckIntervalMinutes = focusCheckIntervalMinutes
        self.infinityModeEnabled = infinityModeEnabled
        self.selectedSkin = selectedSkin
        self.useCustomWaterColor = useCustomWaterColor
        self.whiteNoiseEnabled = whiteNoiseEnabled
        self.whiteNoiseVolume = whiteNoiseVolume
        self.hasSeenOnboarding = hasSeenOnboarding
        self.waterColorEvolution = waterColorEvolution
    }
}
