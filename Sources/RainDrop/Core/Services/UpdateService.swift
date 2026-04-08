import AppKit
import Foundation
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "Update")

@MainActor
final class UpdateService: ObservableObject {
    @Published var availableVersion: String?
    @Published var releaseNotes: String?
    @Published var isUpdating = false
    @Published var updateResult: String?

    private var hasChecked = false

    func checkForUpdate() async {
        guard !hasChecked else { return }
        hasChecked = true

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
        let brewPath: String
        if FileManager.default.fileExists(atPath: "/opt/homebrew/bin/brew") {
            brewPath = "/opt/homebrew/bin/brew"
        } else if FileManager.default.fileExists(atPath: "/usr/local/bin/brew") {
            brewPath = "/usr/local/bin/brew"
        } else {
            updateResult = "Homebrew가 설치되어 있지 않습니다.\n터미널에서 brew install --cask mgm136044/tap/raindrop 으로 업데이트해주세요."
            return
        }

        isUpdating = true

        let scriptContent = """
        #!/bin/zsh
        sleep 2
        \(brewPath) update 2>/dev/null
        if \(brewPath) upgrade --cask mgm136044/tap/raindrop 2>/tmp/raindrop_update.log; then
            sleep 1
            open /Applications/RainDrop.app
        else
            osascript -e 'display notification "업데이트에 실패했습니다. 터미널에서 수동으로 진행해주세요." with title "RainDrop"'
        fi
        rm -f /tmp/raindrop_update.sh
        """

        let scriptPath = "/tmp/raindrop_update.sh"

        do {
            try scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: scriptPath
            )
        } catch {
            logger.error("스크립트 파일 생성 실패: \(error.localizedDescription, privacy: .public)")
            isUpdating = false
            updateResult = "업데이트 준비 실패"
            return
        }

        let launcher = Process()
        launcher.executableURL = URL(fileURLWithPath: "/bin/zsh")
        launcher.arguments = ["-c", "nohup \(scriptPath) > /dev/null 2>&1 &"]
        launcher.standardOutput = FileHandle.nullDevice
        launcher.standardError = FileHandle.nullDevice

        do {
            try launcher.run()
            launcher.waitUntilExit()

            guard launcher.terminationStatus == 0 else {
                logger.error("런처 종료 코드: \(launcher.terminationStatus)")
                isUpdating = false
                updateResult = "업데이트 스크립트 실행 실패"
                return
            }

            logger.notice("업데이트 스크립트 분리 실행됨, 앱 종료 중...")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApplication.shared.terminate(nil)
            }
        } catch {
            logger.error("업데이트 스크립트 실행 실패: \(error.localizedDescription, privacy: .public)")
            isUpdating = false
            updateResult = "업데이트 실행 실패: \(error.localizedDescription)"
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
