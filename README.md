# RainDrop

집중 시간을 측정하고, 물방울 애니메이션과 양동이 채움으로 진행도를 보여주는 macOS SwiftUI 앱입니다.

## 실행

프로젝트 폴더에서 아래 명령으로 빌드할 수 있습니다.

```bash
swift build
```

실행은 아래 명령을 사용합니다.

```bash
swift run
```

## 현재 포함 기능

- 집중 시작, 일시정지, 재개, 종료
- 물방울 애니메이션
- 집중 시간에 따른 양동이 채움 UI
- 세션 종료 시 JSON 저장
- 히스토리 조회

## 저장 위치

집중 기록은 macOS Application Support 아래 `RainDrop/focus_sessions.json`에 저장됩니다.
