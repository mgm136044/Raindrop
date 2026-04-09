import SwiftUI

// MARK: - Overlay Dismiss Environment

private struct OverlayDismissKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: (@Sendable () -> Void)? = nil
}

extension EnvironmentValues {
    var overlayDismiss: (@Sendable () -> Void)? {
        get { self[OverlayDismissKey.self] }
        set { self[OverlayDismissKey.self] = newValue }
    }
}

// MARK: - Overlay Modal Modifier

extension View {
    func overlayModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        overlay {
            if isPresented.wrappedValue {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPresented.wrappedValue = false
                        }

                    content()
                        .environment(\.overlayDismiss, { isPresented.wrappedValue = false })
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                .onKeyPress(.escape) {
                    isPresented.wrappedValue = false
                    return .handled
                }
            }
        }
        .animation(.spring(duration: 0.25, bounce: 0.1), value: isPresented.wrappedValue)
    }
}
