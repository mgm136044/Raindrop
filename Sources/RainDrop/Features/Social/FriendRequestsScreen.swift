import SwiftUI

struct FriendRequestsScreen: View {
    @ObservedObject var viewModel: FriendsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("친구 요청")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button("닫기") { dismiss() }
                    .buttonStyle(.glass)
            }

            if viewModel.incomingRequests.isEmpty {
                Spacer()
                Text("받은 요청이 없습니다")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(viewModel.incomingRequests) { request in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(request.fromNickname)
                                .font(.system(size: 15, weight: .semibold))
                            Text("친구 요청을 보냈습니다")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Button("수락") {
                                viewModel.acceptRequest(request)
                            }
                            .buttonStyle(.glassProminent)
                            .tint(.green)
                            .controlSize(.small)

                            Button("거절") {
                                viewModel.rejectRequest(request)
                            }
                            .buttonStyle(.glass)
                            .controlSize(.small)
                        }
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
        .frame(width: 400, height: 400)
    }
}
