# RainDrop macOS - Secure Coding Audit (KISA 7 Categories)

**Date**: 2026-04-11  
**Target**: `/Sources/RainDrop/` (88 Swift files)  
**Version**: v2.9.0  

---

## 1. Input Data Validation (입력 데이터 검증)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| SC-IV-01 | Developer code validation | **Vulnerable** | `SettingsScreen.swift:264` - Hardcoded developer code `"0530"` is compared in plaintext. This code is embedded in the Release binary and can be extracted via `strings` command. No rate limiting on attempts. |
| SC-IV-02 | TextField input sanitization | **Adequate** | Nickname input in `ProfileSetupScreen` is trimmed with `.trimmingCharacters(in: .whitespacesAndNewlines)`. Email validated by Firebase Auth. |
| SC-IV-03 | URL construction | **Adequate** | Only one `URL(string:)` call in `UpdateService.swift:20` using a constant (`AppConstants.githubReleasesAPI`). No user-controlled URL construction. |
| SC-IV-04 | Shell command execution (UpdateService) | **Partial** | `UpdateService.swift:91-109` - Shell script constructed via string interpolation with `brewPath` and `scriptPath`. `brewPath` is validated to exist at known paths (`/opt/homebrew/bin/brew` or `/usr/local/bin/brew`), and `scriptPath` is generated via `mktemp`. However, `scriptPath` is interpolated into shell commands without quoting. Risk: if `mktemp` returns a path with special characters (unlikely on macOS but theoretically possible), command injection could occur. |
| SC-IV-05 | JSONFileStore filename param | **Adequate** | `JSONFileStore.fileURL(for:)` receives hardcoded filenames from `AppConstants`. No user-supplied filenames. |
| SC-IV-06 | Firestore document field injection | **Adequate** | UID comes from Firebase Auth (`Auth.auth().currentUser?.uid`), not user input. Invite code is server-generated. |

---

## 2. Security Features (보안 기능)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| SC-SF-01 | Hardcoded Firebase API Key (CWE-321) | **Partial** | `FirebaseSecrets.swift:14` contains `apiKey = "AIzaSyCJv6SNTtGY314N3DtZ97TrM4AEkcVi0ag"`. File is in `.gitignore` and NOT tracked in git (verified). However, the key is compiled into the binary. Mitigated by: (1) Firebase API keys are designed to be public-facing, (2) security comment recommends App Check + bundle ID binding. **Recommendation**: Verify Firebase Console has API key restrictions actually applied. |
| SC-SF-02 | Hardcoded developer code (CWE-259) | **Vulnerable** | `"0530"` hardcoded in `SettingsScreen.swift:264`. Anyone with `strings RainDrop` can extract it. Developer mode toggle is accessible in Release builds. |
| SC-SF-03 | Plaintext JSON storage (CWE-312) | **Partial** | `JSONFileStore` saves `focus_sessions.json` and settings as plaintext JSON in `~/Library/Application Support/RainDrop/`. Data contains focus session history (timestamps, durations). Not highly sensitive but unencrypted. macOS sandbox and file permissions provide baseline protection. |
| SC-SF-04 | Keychain usage | **Adequate** | Firebase Auth uses iOS/macOS Keychain for credential storage via `Auth.auth().useUserAccessGroup(nil)`. |
| SC-SF-05 | Cryptographic randomness (CWE-330) | **Adequate** | `AppleSignInCoordinator.swift:89` uses `SecRandomCopyBytes` for nonce generation. `AuthViewModel.swift:172` uses `SecRandomCopyBytes` for invite code generation. `GrowthState.swift:4` uses `UInt64.random` for plant seed (non-security context, acceptable). |
| SC-SF-06 | HTTPS only (CWE-319) | **Adequate** | No `http://` URLs found. GitHub API accessed via HTTPS. |

---

## 3. Time and State (시간 및 상태)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| SC-TS-01 | Race conditions in async code | **Adequate** | All ViewModels are `@MainActor`-isolated. `TimerService` is `@MainActor`. Firebase operations use structured `Task` blocks within `@MainActor` context. No unprotected shared mutable state detected. |
| SC-TS-02 | repeatForever animations | **Adequate** | `BucketView.swift` and `FacetOverlay.swift` use `repeatForever` within SwiftUI animation context. These are lifecycle-managed by SwiftUI view hierarchy. No manual cleanup needed. |
| SC-TS-03 | Timer resource management | **Adequate** | `TimerService.stop()` properly calls `invalidate()` and sets `timer = nil`. `start()` calls `stop()` first to prevent duplicates. |

---

## 4. Error Handling (오류 처리)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| SC-EH-01 | Error message information leak (CWE-209) | **Partial** | `AuthViewModel.swift:208` exposes internal Firebase error messages: `"\(context) 내부 오류: \(underlyingMessage)"` for error code 17999. `AuthViewModel.swift:210` exposes error code and description: `"\(context) 실패 [\(nsError.code)]: \(error.localizedDescription)"`. These are shown in UI (`errorMessage` property is `@Published`). |
| SC-EH-02 | Logger privacy annotations | **Adequate** | All `logger.error` calls properly use `privacy: .public` only for non-sensitive strings (error descriptions, version strings). No credentials or tokens logged. |
| SC-EH-03 | Print statements in production | **Partial** | `FirestoreService.swift:24,29` has `print()` statements that are wrapped in `#if DEBUG`. Acceptable, but `os.Logger` would be more consistent. |
| SC-EH-04 | UpdateService error to user | **Adequate** | Update failure messages shown to user are generic ("업데이트 준비 실패"). Detailed errors go only to `logger`. |

---

## 5. Code Quality (코드 품질)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| SC-CQ-01 | Force unwrap (CWE-476) | **Vulnerable** | `AppleSignInCoordinator.swift:80` - `NSApp.windows.first!` will crash if called when no windows exist. Should use `NSApp.windows.first ?? NSWindow()` or handle gracefully. |
| SC-CQ-02 | AVAudioPlayer cleanup | **Adequate** | `BackgroundSoundService.teardown()` properly stops and nils the player. `play()` cleans up previous player before creating new one. |
| SC-CQ-03 | Task cancellation | **Partial** | Fire-and-forget `Task {}` blocks in ViewModels (e.g., `AuthViewModel.swift:38`, `TimerViewModel.swift:131`) are not stored or cancelled on deinit. For ViewModels that outlive their views, this is acceptable, but could cause issues during rapid navigation. |

---

## 6. Encapsulation (캡슐화)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| SC-EN-01 | Debug code in Release (CWE-615) | **Partial** | Developer mode with code `"0530"` is accessible in Release builds. No `#if DEBUG` guard around the developer code section in `SettingsScreen.swift:256-270`. |
| SC-EN-02 | #if DEBUG blocks | **Adequate** | Only 2 `#if DEBUG` blocks found, both in `FirestoreService.swift` for `print()` statements. Properly guarded. |
| SC-EN-03 | TODO/FIXME comments | **Adequate** | No TODO/FIXME comments found in production code. |
| SC-EN-04 | Print statements | **Adequate** | Only 2 `print()` calls, both inside `#if DEBUG`. |

---

## 7. API Misuse (API 오용)

| Code | Item | Verdict | Detail |
|------|------|---------|--------|
| SC-AM-01 | URL scheme security | **Adequate** | All URLs use HTTPS. GitHub API uses proper Accept header. |
| SC-AM-02 | Process execution safety | **Partial** | `UpdateService.swift` uses `Process()` to execute shell commands. Uses `mktemp` for temp file (good). Sets `0o700` permissions on script (good). However, the shell script content uses unquoted variable interpolation within the heredoc, which could theoretically be exploited if `brewPath` contained special characters (very unlikely given the validation). |
| SC-AM-03 | Deprecated API usage | **Adequate** | No deprecated API usage detected. Uses modern SwiftUI, Combine, and structured concurrency patterns. |

---

## Summary

| Severity | Count | Items |
|----------|-------|-------|
| **Critical** | 0 | - |
| **High** | 1 | SC-SF-02 (hardcoded dev code in Release) |
| **Medium** | 4 | SC-IV-01, SC-IV-04, SC-CQ-01, SC-EN-01 |
| **Low** | 4 | SC-SF-03, SC-EH-01, SC-EH-03, SC-CQ-03 |
| **Adequate** | 16 | All other items |

**Total findings: 9 (0 Critical, 1 High, 4 Medium, 4 Low)**
