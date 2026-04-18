---
name: RecipeAI 개발
description: iOS RecipeAI 프로젝트 개발 및 유지보수 가이드
type: development-guide
---

# RecipeAI 개발 스킬

## 개요

RecipeAI는 Gemini 2.0 Flash API를 사용하여 음식/음료 사진을 분석하고 재료, 조리법, 팁을 제공하는 iOS 앱입니다.

## 빠른 시작

### 1단계: 프로젝트 생성
```bash
cd /Users/neotolee/workspaces/recipe
/opt/homebrew/bin/xcodegen generate
open RecipeAI.xcodeproj
```

### 2단계: 빌드 및 실행
- **시뮬레이터**: iPhone 15 선택 → Product > Run
- **실기기**: iPhone 13 Pro 연결 → Apple ID 로그인 → Product > Run

## 핵심 컴포넌트

### HomeView (메인 화면)
**위치**: `Sources/Views/HomeView.swift`

- 사진 선택 UI (카메라/갤러리)
- "AI로 분석하기" 버튼
- fullScreenCover로 전체 화면 표시

**수정 시 주의**:
- .sheet → .fullScreenCover (화면 크기 문제)
- isAnalyzing 상태 관리 중요

### ProCameraView (카메라)
**위치**: `Sources/Views/ProCameraView.swift`

AVFoundation 기반의 커스텀 카메라:
- **플래시**: 자동/켜짐/꺼짐 토글
- **줌**: 핀치 제스처 (1.0x ~ 5.0x)
- **캡처**: 중앙 하단 버튼

**트러블슈팅**:
- 시뮬레이터: 실제 카메라 없음 → 실기기 테스트
- 플래시 작동 확인: flashMode 설정 후 capturePhoto() 호출

### GeminiService (AI 분석)
**위치**: `Sources/Services/GeminiService.swift`

- Gemini 2.0 Flash 모델 호출
- 이미지 압축: 75%
- JSON 파싱 + 정규식 캐싱
- API 키: Info.plist의 GEMINI_API_KEY

**프롬프트 수정 시**:
```swift
let prompt = """
이 이미지를 분석해서 정확히 다음 JSON 형식으로만 응답해주세요:
{
  "foodName": "음식/음료/차 이름",
  "ingredients": [{"name": "재료명", "amount": "분량"}],
  "steps": ["단계1", "단계2"],
  "tips": "팁 또는 null"
}
"""
```

### SavedRecipe (로컬 저장)
**위치**: `Sources/Models/SavedRecipe.swift`

SwiftData @Model로 정의된 저장 모델:
- id: UUID
- foodName: String
- ingredientsJSON: Data (JSON 인코딩)
- steps: [String]
- tips: String?
- imageData: Data? (JPEG)
- createdAt: Date

## 개발 워크플로우

### 새 기능 추가
1. **요구사항 정의**: 기능 범위 명확히
2. **데이터 모델**: SavedRecipe 수정 필요시 버전 관리
3. **View 구현**: SwiftUI로 UI 작성
4. **Service 통합**: 필요시 GeminiService 프롬프트 수정
5. **테스트**: iPhone 실기기에서 검증
6. **Git 커밋**: 의미있는 커밋 메시지

### 버그 수정
1. **재현**: 구체적인 단계 기록
2. **원인 분석**: 로그 확인 (Console, print문)
3. **수정 구현**: 최소 범위 수정
4. **테스트**: 수정 전후 비교
5. **Git 커밋**: fix: 프리픽스 사용

### 성능 최적화
1. **프로파일링**: Xcode Instruments
2. **병목 지점**: 이미지 처리, API 호출, SwiftData 쿼리
3. **최적화 적용**: 캐싱, 비동기 처리
4. **검증**: 실기기에서 측정

## 일반적인 작업

### 프롬프트 수정 (AI 분석 결과 개선)
```bash
# 1. GeminiService.swift의 prompt 문자열 수정
# 2. 재빌드: xcodegen generate + Xcode rebuild
# 3. iPhone에서 테스트
```

### API 키 변경
```yaml
# project.yml에서 수정
info:
  properties:
    GEMINI_API_KEY: "새 API 키"

# 그 후 xcodegen generate
```

### UI 텍스트 수정
- HomeView: 타이틀, 설명 텍스트
- ResultView: 섹션 제목
- SavedListView: 빈 상태 메시지

모두 한국어이며, 이모지 금지 (명시적 요청 시 제외)

### 새 화면 추가
1. **파일 생성**: `Sources/Views/NewView.swift`
2. **구조체 정의**: View 프로토콜 구현
3. **탭 추가**: RecipeAIApp.swift의 TabView에 추가
4. **라우팅**: 필요시 NavigationStack 설정

## 배포 전 체크리스트

- [ ] API 키 환경 변수로 관리 확인
- [ ] 민감한 정보 git 커밋 제외 확인
- [ ] iPhone 실기기 최종 테스트
- [ ] App Store 앱 아이콘 확인
- [ ] Info.plist 권한 설정 완료
- [ ] 번들 ID 변경 (배포 시)

## 문제 해결 가이드

### "Cannot find GEMINI_API_KEY" 오류
**원인**: Info.plist에 API 키 미설정
**해결**: 
1. project.yml에 GEMINI_API_KEY 추가
2. `xcodegen generate` 실행
3. Xcode rebuild

### Gemini API 429 오류
**원인**: 일일 무료 할당량 초과
**해결**: 
- 기다리거나 결제 계정 전환
- 개발 중: 테스트 데이터 사용

### 카메라가 검은 화면만 표시
**원인**: AVFoundation 세션 시작 실패 또는 권한 문제
**해결**:
1. Info.plist 권한 확인: NSCameraUsageDescription
2. 실기기 카메라 권한 설정 확인
3. 시뮬레이터: 실제 카메라 없음 → 실기기 테스트

### JSON 파싱 오류
**원인**: Gemini 응답이 유효한 JSON이 아님
**해결**:
1. 프롬프트 수정: "정확히 다음 JSON 형식으로만"
2. 응답 예시 추가
3. 에러 메시지 로깅 확인

## 코드 스타일

### 네이밍
- 함수: camelCase (private 함수는 _ 접두사)
- 변수: camelCase
- 타입: PascalCase
- 상수: UPPER_SNAKE_CASE (필요시만)

### 주석
- 필요시만 작성 (WHY를 설명)
- 다국어 주석 금지 (한국어만)
- 주석 예: `// 사용자가 줌을 조절할 때 비율 저장`

### 코드 포맷팅
- 들여쓰기: 2 스페이스 (Xcode 기본)
- 라인 길이: 120 자 이상 피하기
- 함수 길이: 50줄 이내 권장

## 유용한 도구

| 도구 | 경로 | 용도 |
|------|------|------|
| XcodeGen | `/opt/homebrew/bin/xcodegen` | Xcode 프로젝트 생성 |
| rsvg-convert | `/opt/homebrew/bin/rsvg-convert` | SVG → PNG 변환 |
| gh | (기본 설치) | GitHub CLI |

## 참고 자료

- [SwiftUI 공식 문서](https://developer.apple.com/xcode/swiftui/)
- [AVFoundation 카메라](https://developer.apple.com/av-foundation/)
- [SwiftData](https://developer.apple.com/swiftdata/)
- [Gemini API](https://ai.google.dev/)
