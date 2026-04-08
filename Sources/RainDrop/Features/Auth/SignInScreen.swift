import SwiftUI
import AuthenticationServices

struct SignInScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && password.count >= 6
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("RainDrop 소셜")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.titleText)

                Text("친구들과 함께 집중하고 경쟁하세요")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            // Apple Sign In
            Button {
                authViewModel.signInWithApple()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18, weight: .medium))
                    Text("Apple로 로그인")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: 280)
                .padding(.vertical, 10)
            }
            .buttonStyle(.glassProminent)
            .tint(.black)
            .disabled(authViewModel.isLoading)

            HStack {
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 1)
                Text("또는")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 1)
            }
            .frame(maxWidth: 280)

            // Email/Password
            VStack(spacing: 12) {
                TextField("이메일", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 280)
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }

                SecureField("비밀번호 (6자 이상)", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 280)
                    .focused($focusedField, equals: .password)

                Button {
                    if isSignUp {
                        authViewModel.signUpWithEmail(email: email, password: password)
                    } else {
                        authViewModel.signInWithEmail(email: email, password: password)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text(isSignUp ? "이메일로 회원가입" : "이메일로 로그인")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: 280)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.glassProminent)
                .tint(AppColors.accentBlue)
                .disabled(!isFormValid || authViewModel.isLoading)

                Button(isSignUp ? "이미 계정이 있나요? 로그인" : "계정이 없나요? 회원가입") {
                    isSignUp.toggle()
                    authViewModel.errorMessage = nil
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.accentBlue)
            }

            if authViewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            }

            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.danger)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(0.3))
                focusedField = .email
            }
        }
    }
}
