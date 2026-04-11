import AVFoundation
import Foundation
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "BackgroundSound")

/// macOS 시스템 사운드 파일을 AVAudioPlayer로 직접 재생.
/// 인터넷 불필요, 시스템 설정 변경 없음, 10종 사운드 지원.
@MainActor
final class BackgroundSoundService: ObservableObject {
    @Published private(set) var isPlaying = false

    private var audioPlayer: AVAudioPlayer?

    // MARK: - Public API

    func play(sound: BackgroundSound, volume: Double) {
        // 이전 플레이어 정리 (중복 재생 방지)
        audioPlayer?.stop()
        audioPlayer = nil

        guard let url = Self.soundURL(for: sound) else {
            logger.error("번들에 사운드 파일 없음: BackgroundSounds/\(sound.rawValue, privacy: .public).m4a")
            isPlaying = false
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = clampedVolume(volume)
            player.prepareToPlay()
            if player.play() {
                audioPlayer = player
                isPlaying = true
                logger.notice("재생 시작: \(sound.displayName)")
            } else {
                isPlaying = false
                logger.error("AVAudioPlayer.play() 실패: \(sound.displayName)")
            }
        } catch {
            isPlaying = false
            logger.error("사운드 로드 실패 (\(sound.rawValue, privacy: .public)): \(error.localizedDescription, privacy: .public)")
        }
    }

    func resumeAudio() {
        guard let player = audioPlayer else { return }
        isPlaying = player.play()
    }

    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func setVolume(_ volume: Double) {
        audioPlayer?.volume = clampedVolume(volume)
    }

    func teardown() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    // MARK: - Private

    private func clampedVolume(_ v: Double) -> Float {
        Float(max(0, min(1, v)))
    }

    /// SPM 리소스 번들에서 사운드 파일 URL 탐색
    private static func soundURL(for sound: BackgroundSound) -> URL? {
        // SPM이 생성하는 리소스 번들 이름
        let bundleName = "RainDrop_RainDrop"

        // 1) 앱 번들 내 Resources 디렉터리에서 탐색
        if let resourceBundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle"),
           let resourceBundle = Bundle(path: resourceBundlePath),
           let url = resourceBundle.url(forResource: sound.rawValue, withExtension: "m4a", subdirectory: "BackgroundSounds") {
            return url
        }

        // 2) 실행 파일 옆 번들 탐색 (개발 환경)
        let executableDir = Bundle.main.bundleURL.deletingLastPathComponent()
        let devBundlePath = executableDir.appendingPathComponent("\(bundleName).bundle")
        if let devBundle = Bundle(url: devBundlePath),
           let url = devBundle.url(forResource: sound.rawValue, withExtension: "m4a", subdirectory: "BackgroundSounds") {
            return url
        }

        return nil
    }
}

// MARK: - 사운드 종류

enum BackgroundSound: String, CaseIterable, Codable {
    case rain = "Rain"
    case rainOnRoof = "RainOnRoof"
    case ocean = "Ocean"
    case stream = "Stream"
    case fire = "Fire"
    case night = "Night"
    case quietNight = "QuietNight"
    case airplane = "Airplane"

    var filename: String { rawValue + ".m4a" }

    var displayName: String {
        switch self {
        case .rain: return "빗소리"
        case .rainOnRoof: return "지붕 위 빗소리"
        case .ocean: return "바다"
        case .stream: return "시냇물"
        case .fire: return "모닥불"
        case .night: return "밤"
        case .quietNight: return "고요한 밤"
        case .airplane: return "비행기"
        }
    }

    var emoji: String {
        switch self {
        case .rain, .rainOnRoof: return "🌧️"
        case .ocean: return "🌊"
        case .stream: return "🏞️"
        case .fire: return "🔥"
        case .night, .quietNight: return "🌙"
        case .airplane: return "✈️"
        }
    }

    // Backward compatibility: old saved values map to default
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "WhiteNoise", "PinkNoise", "BrownNoise":
            self = .rain  // Fall back to rain for removed sounds
        default:
            self = BackgroundSound(rawValue: rawValue) ?? .rain
        }
    }
}
