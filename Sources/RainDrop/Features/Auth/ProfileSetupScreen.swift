import SwiftUI

struct ProfileSetupScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var nickname = ""

    private var isValid: Bool {
        nickname.count >= 2 && nickname.count <= 12
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("프로필 설정")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.titleText)

                Text("친구들에게 보여질 닉네임을 입력하세요")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                TextField("닉네임 (2~12자)", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 280)

                Text("\(nickname.count)/12")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Button {
                    authViewModel.createProfile(nickname: nickname)
                } label: {
                    Text("시작하기")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: 280)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accentBlue)
                .disabled(!isValid || authViewModel.isLoading)

                if authViewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.red)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
