import Foundation
import FirebaseCore
import FirebaseAuth
import os

private let logger = Logger(subsystem: "com.mingyeongmin.RainDrop", category: "FirebaseConfig")

enum FirebaseConfig {
    static func configure() {
        let options = FirebaseOptions(
            googleAppID: "1:424510452328:ios:b187d6d717d2bb1a9a41dd",
            gcmSenderID: "424510452328"
        )
        options.apiKey = "AIzaSyCJv6SNTtGY314N3DtZ97TrM4AEkcVi0ag"
        options.projectID = "raibdrop"
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
