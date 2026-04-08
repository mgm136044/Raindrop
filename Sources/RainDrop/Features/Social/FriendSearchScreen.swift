import SwiftUI

struct FriendSearchScreen: View {
    @ObservedObject var viewModel: FriendsViewModel
    @State private var searchText = ""
    @State private var searchMode: SearchMode = .nickname
    @Environment(\.dismiss) private var dismiss

    enum SearchMode: String, CaseIterable {
        case nickname = "닉네임"
        case inviteCode = "초대 코드"
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("친구 찾기")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button("닫기") { dismiss() }
                    .buttonStyle(.glass)
            }

            Picker("검색 방식", selection: $searchMode) {
                ForEach(SearchMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 8) {
                TextField(
                    searchMode == .nickname ? "닉네임 입력" : "6자리 코드 입력",
                    text: $searchText
                )
                .textFieldStyle(.roundedBorder)

                Button("검색") {
                    switch searchMode {
                    case .nickname:
                        viewModel.searchByNickname(searchText)
                    case .inviteCode:
                        viewModel.searchByInviteCode(searchText)
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(AppColors.accentBlue)
                .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if viewModel.searchResults.isEmpty {
                Spacer()
                Text("검색 결과가 없습니다")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(viewModel.searchResults) { user in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.nickname)
                                .font(.system(size: 15, weight: .semibold))
                            Text("코드: \(user.inviteCode)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("친구 요청") {
                            viewModel.sendRequest(to: user)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(AppColors.accentBlue)
                        .controlSize(.small)
                    }
                    .padding(.vertical, 4)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.danger)
            }
        }
        .padding(20)
        .frame(width: 420, height: 480)
        .onDisappear {
            viewModel.clearSearch()
        }
    }
}
