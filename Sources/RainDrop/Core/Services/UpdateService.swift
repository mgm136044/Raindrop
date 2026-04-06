import Foundation
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "Update")

@MainActor
final class UpdateService: ObservableObject {
    @Published var availableVersion: String?
    @Published var releaseNotes: String?
    @Published var isUpdating = false
    @Published var updateResult: String?

    func checkForUpdate() async {
        guard let url = URL(string: AppConstants.githubReleasesAPI) else { return }

        do {
            var request = URLRequest(url: url)
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 10

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                logger.notice("GitHub API 응답 실패: HTTP \(statusCode)")
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tagName = json["tag_name"] as? String else {
                logger.notice("GitHub API 응답 파싱 실패")
                return
            }

            let latestVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
            let body = json["body"] as? String

            logger.notice("최신 버전: \(latestVersion, privacy: .public), 현재 버전: \(AppConstants.appVersion, privacy: .public)")

            if isNewer(latestVersion, than: AppConstants.appVersion) {
                availableVersion = latestVersion
                releaseNotes = body
            }
        } catch {
            logger.error("업데이트 확인 실패: \(error.localizedDescription, privacy: .public)")
        }
    }

    func performUpdate() {
        isUpdating = true
        updateResult = nil

        let brewPath = FileManager.default.fileExists(atPath: "/opt/homebrew/bin/brew")
            ? "/opt/homebrew/bin/brew"
            : "/usr/local/bin/brew"

        Task.detached { [weak self] in
            let result = Self.runBrewUpgrade(brewPath: brewPath)
            await MainActor.run {
                self?.updateResult = result
                self?.isUpdating = false
            }
        }
    }

    private nonisolated static func runBrewUpgrade(brewPath: String) -> String {
        // 1. brew update로 tap 캐시 갱신
        let updateProcess = Process()
        updateProcess.executableURL = URL(fileURLWithPath: brewPath)
        updateProcess.arguments = ["update"]
        updateProcess.standardOutput = Pipe()
        updateProcess.standardError = Pipe()

        do {
            try updateProcess.run()
            updateProcess.waitUntilExit()
            logger.notice("brew update 완료 (exit: \(updateProcess.terminationStatus))")
        } catch {
            logger.error("brew update 실패: \(error.localizedDescription, privacy: .public)")
        }

        // 2. brew upgrade로 실제 업그레이드
        let process = Process()
        process.executableURL = URL(fileURLWithPath: brewPath)
        process.arguments = ["upgrade", "--cask", "mgm136044/tap/raindrop"]

        let outPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = outPipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = outPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            if process.terminationStatus == 0 {
                logger.notice("brew upgrade 성공")
                return "업데이트 완료! 앱을 재시작해주세요."
            } else {
                logger.error("brew upgrade 실패: \(output, privacy: .public)")
                return "업데이트 실패: \(output)"
            }
        } catch {
            logger.error("brew 실행 실패: \(error.localizedDescription, privacy: .public)")
            return "업데이트 실행 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Private

    private func isNewer(_ remote: String, than local: String) -> Bool {
        let r = remote.split(separator: ".").compactMap { Int($0) }
        let l = local.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(r.count, l.count) {
            let rv = i < r.count ? r[i] : 0
            let lv = i < l.count ? l[i] : 0
            if rv > lv { return true }
            if rv < lv { return false }
        }
        return false
    }
}
