import Foundation
import FirebaseCore
import FirebaseAuth
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "FirebaseConfig")

enum FirebaseConfig {
    static func configure() {
        let options = FirebaseOptions(
            googleAppID: FirebaseSecrets.googleAppID,
            gcmSenderID: FirebaseSecrets.gcmSenderID
        )
        options.apiKey = FirebaseSecrets.apiKey
        options.projectID = FirebaseSecrets.projectID
        options.bundleID = "com.mingyeongmin.RainDrop"

        FirebaseApp.configure(options: options)

        // 공유 Keychain 그룹을 강제하지 않고 앱 기본 Keychain을 사용
        do {
            try Auth.auth().useUserAccessGroup(nil)
            logger.notice("useUserAccessGroup(nil) succeeded — using default keychain access group")
        } catch {
            let nsError = error as NSError
            logger.error("useUserAccessGroup(nil) failed: domain=\(nsError.domain, privacy: .public) code=\(nsError.code) — \(nsError.localizedDescription, privacy: .public)")
        }
    }
}
