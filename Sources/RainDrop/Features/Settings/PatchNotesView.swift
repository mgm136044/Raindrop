import SwiftUI

private struct PatchNote {
    let version: String
    let date: String
    let changes: [String]
}

// MARK: - Patch notes data (shared)

private let patchNotes: [PatchNote] = [
        PatchNote(version: "2.7.0", date: "2026.04.11", changes: [
            "양동이 스킨 전면 리디자인 — Apple 디자인 철학 기반 6종 고유 형태/재질",
            "물 애니메이션 안정성 대폭 개선 — TimelineView 기반 (프리즈 버그 수정)",
            "스킨별 동적 비/물 영역 — 입구, 바닥, 채움 높이 자동 적응",
            "배경 사운드 품질 업그레이드 — Apple ComfortSounds 고품질 오디오 적용",
            "노이즈 3종 제거 → 비행기 앰비언스 추가 (총 8종)",
            "배경 사운드 선택 UX 개선 — 블럭 전체 클릭 가능",
            "개발자 모드 코드 토글 방식으로 변경",
        ]),
        PatchNote(version: "2.6.1", date: "2026.04.10", changes: [
            "타이머 실행 중 배경 사운드 활성화 시 정상 동작하도록 수정",
            "일시정지 상태에서 배경 사운드 설정 변경 지원",
        ]),
        PatchNote(version: "2.6.0", date: "2026.04.10", changes: [
            "배경 사운드 기능 전면 개편 — 10종 사운드 앱 내 재생 (빗소리, 바다, 시냇물, 모닥불 등)",
            "WKWebView 제거 — 인터넷 없이 사운드 재생 가능",
            "무한 모드 양동이 코인이 히스토리에 반영되지 않는 버그 수정",
        ]),
        PatchNote(version: "2.5.3", date: "2026.04.09", changes: [
            "온보딩 다시 보기 동작하지 않는 버그 수정",
        ]),
        PatchNote(version: "2.5.2", date: "2026.04.09", changes: [
            "백색소음 화면 플레이어 리로드 안내 문구 복원",
        ]),
        PatchNote(version: "2.5.1", date: "2026.04.09", changes: [
            "보안 강화 — 업데이트 스크립트 경로 예측 방지 (mktemp)",
            "보안 강화 — 초대코드 암호학적 난수 적용",
            "온보딩 애니메이션 안정성 향상 (Task 취소 지원)",
        ]),
        PatchNote(version: "2.5.0", date: "2026.04.09", changes: [
            "설정 화면 탭 분할 — 집중/환경/성장/기타 4개 탭으로 스크롤 제거",
            "온보딩 다시보기 수정 (중첩 시트 문제 해결)",
            "패치노트 오버레이 표시 방식 개선",
        ]),
        PatchNote(version: "2.4.1", date: "2026.04.09", changes: [
            "0초 세션 drain 애니메이션 버그 수정",
            "집중 시간 기록 정밀도 개선 (반올림 적용)",
            "개발자 모드 앱 시작 시 즉시 동기화",
            "집중 확인 알림 타이밍 안정성 향상",
            "업데이트 수동 재확인 지원",
            "거품 파티클 일관성 수정",
        ]),
        PatchNote(version: "2.4.0", date: "2026.04.09", changes: [
            "성능 최적화 — 파도 렌더링 80% 가속 (sin 룩업 테이블)",
            "설정 디스크 읽기 캐싱 (세션당 5~7회 → 0회)",
            "비 파티클 메모리 할당 80배 감소",
            "배경 색상 계산 최적화",
            "집중 확인 알림 세션 중 재활성화 지원",
        ]),
        PatchNote(version: "2.3.1", date: "2026.04.09", changes: [
            "깊은 바다 배경 거품 애니메이션 수정 및 가시성 향상",
            "배경 테마 적용 시 부드러운 전환 애니메이션 추가",
            "타이머 실행 중에도 배경 테마 반영 (30% 블렌딩)",
            "개발자 모드 추가 (설정 → 기타)",
        ]),
        PatchNote(version: "2.3.0", date: "2026.04.09", changes: [
            "프리미엄 바다 스티커 5종 추가 (돌고래, 해파리, 고래, 산호초, 문어)",
            "배경 꾸미기 기능 도입 — 양동이 코인으로 배경 구매/적용",
            "깊은 바다 배경 테마 추가",
        ]),
        PatchNote(version: "2.2.0", date: "2026.04.09", changes: [
            "물 파도 애니메이션 부드러움 개선 (GPU 렌더링 최적화)",
            "배경 회색 타원 구름 제거 (Apple 디자인 정리)",
        ]),
        PatchNote(version: "2.1.1", date: "2026.04.08", changes: [
            "wave 애니메이션 간헐적 멈춤 수정 (animatableData 격리)",
        ]),
        PatchNote(version: "2.1.0", date: "2026.04.08", changes: [
            "Apple 디자인 철학 적용 — 단일 악센트 블루, 순수 검정 배경",
            "macOS 26 Liquid Glass 전면 적용 (버튼, 헤더, 필, 배너)",
            "모달 헤더 Apple 스타일 — 중앙 타이틀 + 완료 버튼",
            "양동이 탭 시 물 물리 반응 (관성 슬로싱)",
            "모든 양동이에 인터랙션 적용 (메인, 주간, 스티커 편집, 온보딩)",
            "타이머+정보 필 통합 캡슐 (세션 중 Glass.clear)",
            "deprecated onChange API 전체 마이그레이션",
            "색상 시스템 간소화 (30개 → 8개 코어 + 레거시 별칭)",
        ]),
        PatchNote(version: "2.0.3", date: "2026.04.08", changes: [
            "업데이트 무한 루프 수정 (앱 버전 불일치 해소)",
            "업데이트 시 brew 미설치 감지 + 에러 알림",
            "업데이트 실패 시 macOS 알림으로 안내",
            "업데이트 중 로딩 오버레이 정상 표시",
        ]),
        PatchNote(version: "2.0.2", date: "2026.04.08", changes: [
            "스티커 시스템 재구축 — 별도 편집 화면으로 분리",
            "스티커 배치: 팔레트에서 탭으로 추가",
            "스티커 삭제: 리스트에서 개별/전체 삭제",
            "스티커 위치: 프리뷰에서 드래그로 조정",
        ]),
        PatchNote(version: "2.0.1", date: "2026.04.07", changes: [
            "타이머 UI 텍스트/버튼 크기 확대 (가독성 향상)",
        ]),
        PatchNote(version: "2.0.0", date: "2026.04.07", changes: [
            "\"채움으로 삶의 밀도를 기록한다\" — 전면 UI/UX 개편",
            "양동이 중심 레이아웃 (ZStack 오버레이 구조)",
            "동적 비 강도 — 진행도에 따라 이슬비→폭우",
            "3중 사인파 물 + 수면 반사 + 물방울 튀김",
            "진행도별 하늘 변화 (새벽→흐림→폭풍→개임)",
            "양동이 넘침 연출 — 금빛 파티클 버스트",
            "밀도 캘린더 — 미니 양동이 히트맵 + 주간 뷰",
            "환경 진화 시스템 (맨땅→풀→꽃→나무→숲→호수)",
            "날씨 시스템 (연속 집중일수에 따라 흐림→무지개)",
            "체험형 온보딩 — 빗방울이 떨어지고 양동이가 채워지는 경험",
            "물 색상 자연 진화 — 집중 시간에 따라 색이 깊어짐",
        ]),
        PatchNote(version: "1.6.0", date: "2026.04.07", changes: [
            "메인 화면에 현재 버전 표시",
            "앱 실행 시 자동 업데이트 확인 기능 추가",
            "새 버전 발견 시 업데이트 팝업 (brew upgrade 연동)",
            "패치노트 기능 추가",
        ]),
        PatchNote(version: "1.5.0", date: "2026.04.06", changes: [
            "첫 실행 시 4단계 온보딩 페이지 추가",
            "설정에서 온보딩 다시 보기 가능",
        ]),
        PatchNote(version: "1.4.0", date: "2026.04.06", changes: [
            "백색소음 토글 OFF 시 WebView 완전 해제",
            "토글 ON 시 WebView 재로드 (재생 버튼 표시)",
            "재생 후 하얀 화면 방지 (CSS 개선)",
        ]),
        PatchNote(version: "1.3.0", date: "2026.04.06", changes: [
            "백색소음 기능을 독립 화면으로 분리",
            "백색소음 토글 OFF 시 오디오 즉시 정지 버그 수정",
        ]),
        PatchNote(version: "1.2.0", date: "2026.04.06", changes: [
            "무한 모드에서 순환마다 양동이 코인 적립",
            "집중 확인 10초 타임아웃 (무응답 시 자동 일시정지)",
            "백색소음 기능 추가 (rainymood.com 연동)",
            "버튼 3개에서 2개로 통합 (상태별 전환)",
            "구름 애니메이션 가시성 향상",
            "비 파티클 양동이 폭에 맞춤",
            "앱 종료 시 알림 자동 정리",
        ]),
        PatchNote(version: "1.1.0", date: "2026.04.06", changes: [
            "6종 양동이 스킨 추가 (나무, 철, 백금, 금, 다이아, 무지개)",
            "티어별 스킨 해금 시스템",
            "금 이상 티어에서 물 색상 커스텀 가능",
            "비 파티클 시스템 (작고 많은 빗방울)",
            "구름 애니메이션 추가",
        ]),
        PatchNote(version: "1.0.0", date: "2026.04.06", changes: [
            "RainDrop 첫 출시",
            "집중 타이머 + 양동이 채움 시스템",
            "무한 모드 (끝없는 집중)",
            "메뉴바 타이머 상태 표시",
            "월별 달력 히스토리",
            "스티커 꾸미기 상점",
            "Homebrew 배포 지원",
        ]),
]

struct PatchNotesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            PatchNotesContentView()
        }
        .frame(minWidth: 480, minHeight: 500)
    }

    private var header: some View {
        ZStack {
            Text("패치노트")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            HStack {
                Spacer()
                Button("닫기") { dismiss() }
                    .buttonStyle(.glass)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular)
    }
}

// MARK: - Embeddable content (no @Environment(\.dismiss) — overlay 사용 가능)

struct PatchNotesEmbeddedView: View {
    var body: some View {
        PatchNotesContentView()
    }
}

private struct PatchNotesContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(patchNotes, id: \.version) { note in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("v\(note.version)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(AppColors.primaryText)

                            Text(note.date)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)

                            if note.version == AppConstants.appVersion {
                                Text("현재 버전")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(AppColors.accentBlue)
                                    .clipShape(Capsule())
                            }
                        }

                        ForEach(note.changes, id: \.self) { change in
                            HStack(alignment: .top, spacing: 8) {
                                Text("·")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.accentBlue)
                                Text(change)
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppColors.subtitleText)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.panelBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
        }
    }
}
