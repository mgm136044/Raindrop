#!/bin/bash
set -euo pipefail

# RainDrop 배포 스크립트
# 사용법: ./deploy.sh [--skip-build] [--no-launch] [--social]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="/Applications/RainDrop.app"
IDENTITY="Apple Development: gyeongminmin530@gmail.com (QJ4CVLUF6B)"
ENTITLEMENTS="$SCRIPT_DIR/RainDrop.entitlements"
BUNDLE_ID="com.mingyeongmin.RainDrop"
TEAM_ID="3372U9TU87"

SKIP_BUILD=false
NO_LAUNCH=false
SOCIAL_ENABLED=false

for arg in "$@"; do
    case $arg in
        --skip-build) SKIP_BUILD=true ;;
        --no-launch) NO_LAUNCH=true ;;
        --social) SOCIAL_ENABLED=true ;;
    esac
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  RainDrop 배포 스크립트"
if [ "$SOCIAL_ENABLED" = true ]; then
    echo "  모드: 소셜 기능 포함 (entitlements + profile)"
else
    echo "  모드: 로컬 전용 (배포용)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: 빌드
if [ "$SKIP_BUILD" = false ]; then
    echo ""
    echo "[1/5] 빌드 중..."
    cd "$SCRIPT_DIR"
    swift build -c release 2>&1 | tail -3
    echo "  ✓ 빌드 완료"
else
    echo ""
    echo "[1/5] 빌드 건너뜀 (--skip-build)"
fi

# Step 2: 프로비저닝 프로파일 (소셜 기능 활성화 시에만)
echo ""
if [ "$SOCIAL_ENABLED" = true ]; then
    echo "[2/5] 프로비저닝 프로파일 갱신 중..."

    cd "$SCRIPT_DIR"
    xcodebuild -project RainDrop.xcodeproj \
        -scheme RainDrop \
        -configuration Release \
        -allowProvisioningUpdates \
        -allowProvisioningDeviceRegistration \
        build 2>&1 | grep -q "ProcessProductPackaging" || true

    # 번들 ID가 일치하는 가장 최신 프로파일 찾기
    LATEST_PROFILE=""
    PROFILES_DIR="$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles"

    if [ -d "$PROFILES_DIR" ]; then
        while IFS= read -r profile; do
            [ -z "$profile" ] && continue
            if security cms -D -i "$profile" 2>/dev/null | grep -q "$BUNDLE_ID"; then
                LATEST_PROFILE="$profile"
                break
            fi
        done < <(find "$PROFILES_DIR" -name "*.provisionprofile" \
            -exec stat -f '%m %N' {} \; 2>/dev/null | sort -rn | cut -d' ' -f2-)
    fi

    if [ -z "$LATEST_PROFILE" ]; then
        echo "  ✗ $BUNDLE_ID 에 해당하는 프로비저닝 프로파일을 찾을 수 없습니다."
        echo "    Xcode에서 Apple 계정 로그인 상태를 확인하세요."
        exit 1
    fi

    EXPIRY=$(security cms -D -i "$LATEST_PROFILE" 2>/dev/null | \
        grep -A1 "ExpirationDate" | grep "date" | sed 's/.*<date>\(.*\)<\/date>/\1/')
    echo "  프로파일: $(basename "$LATEST_PROFILE")"
    echo "  만료일: $EXPIRY"
    echo "  ✓ 프로파일 갱신 완료"
else
    echo "[2/5] 프로비저닝 프로파일 건너뜀 (로컬 전용 모드)"
fi

# Step 3: 바이너리 배치
echo ""
echo "[3/5] 바이너리 배치 중..."
pkill -x RainDrop 2>/dev/null || true
sleep 1
cp "$SCRIPT_DIR/.build/release/RainDrop" "$APP_PATH/Contents/MacOS/RainDrop"

# SPM 리소스 번들 복사
BUNDLE_SRC="$SCRIPT_DIR/.build/arm64-apple-macosx/release/RainDrop_RainDrop.bundle"
BUNDLE_DST="$APP_PATH/Contents/Resources/RainDrop_RainDrop.bundle"
if [ -d "$BUNDLE_SRC" ]; then
    rm -rf "$BUNDLE_DST"
    cp -R "$BUNDLE_SRC" "$BUNDLE_DST"
    echo "  ✓ 리소스 번들 복사 완료"
fi
echo "  ✓ 바이너리 복사 완료"

# Step 4: 코드 서명
echo ""
echo "[4/5] 코드 서명 중..."
if [ "$SOCIAL_ENABLED" = true ]; then
    cp "$LATEST_PROFILE" "$APP_PATH/Contents/embedded.provisionprofile"
    codesign --force --sign "$IDENTITY" \
        --entitlements "$ENTITLEMENTS" \
        "$APP_PATH"
    echo "  ✓ 코드 서명 완료 (entitlements + profile 포함)"
else
    # 프로비저닝 프로파일 제거 + 엔타이틀먼트 포함 서명
    # (Keychain 접근 등 소셜 기능에 필요, 프로파일 없이도 동작)
    rm -f "$APP_PATH/Contents/embedded.provisionprofile"
    codesign --force --sign "$IDENTITY" \
        --entitlements "$ENTITLEMENTS" \
        "$APP_PATH"
    echo "  ✓ 코드 서명 완료 (entitlements 포함, profile 없음)"
fi

# Step 5: 검증
echo ""
echo "[5/5] 검증 중..."
if [ "$SOCIAL_ENABLED" = true ]; then
    ENTITLEMENTS_OUTPUT=$(codesign -d --entitlements - "$APP_PATH" 2>&1)
    if echo "$ENTITLEMENTS_OUTPUT" | grep -q "$TEAM_ID.$BUNDLE_ID"; then
        echo "  ✓ keychain-access-groups 확인됨"
    else
        echo "  ✗ entitlements 검증 실패! ($TEAM_ID.$BUNDLE_ID 없음)"
        echo "$ENTITLEMENTS_OUTPUT"
        exit 1
    fi
else
    codesign -v "$APP_PATH" 2>&1 && echo "  ✓ 서명 유효" || echo "  ✗ 서명 검증 실패"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  배포 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 6: 실행
if [ "$NO_LAUNCH" = false ]; then
    echo ""
    echo "앱 실행 중..."
    open "$APP_PATH"
    echo "  ✓ RainDrop 실행됨"
fi
