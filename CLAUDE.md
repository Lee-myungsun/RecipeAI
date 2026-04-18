# RecipeAI 개발 가이드

## 프로젝트 개요

음식/음료 사진을 분석하여 재료, 조리법, 팁을 자동 생성하는 iOS 앱.
Google Gemini 2.0 Flash API를 활용한 멀티모달 AI 분석.

## 기술 스택

| 항목 | 선택 | 버전 |
|------|------|------|
| UI | SwiftUI | iOS 17.0+ |
| 프로젝트 | XcodeGen | - |
| AI | Gemini 2.0 Flash | - |
| DB | SwiftData | iOS 17+ |
| 사진 | PhotosUI + AVFoundation | - |
| 패키지 관리 | SPM | - |

## 개발 환경

- Xcode 26.3+
- iOS 17.0+
- iPhone 15 시뮬레이터 / iPhone 13 Pro 실기기
- Apple ID: hydorgen@gmail.com
- Team ID: MHVVU6XHCC

## 프로젝트 구조

```
Sources/
├── RecipeAIApp.swift              # 앱 엔트리 포인트
├── Models/
│   └── SavedRecipe.swift          # SwiftData 저장 모델
├── Services/
│   └── GeminiService.swift        # Gemini API 통합
└── Views/
    ├── HomeView.swift             # 메인 화면 (사진 선택)
    ├── ResultView.swift           # 분석 결과 표시
    ├── SavedListView.swift        # 저장된 레시피 목록
    ├── RecipeDetailView.swift     # 레시피 상세보기
    ├── ProCameraView.swift        # 카메라 UI (AVFoundation)
    └── PHPickerView.swift         # 갤러리 선택 (PhotosUI)
```

## 주요 파일 설명

### GeminiService.swift
- Google Gemini 2.0 Flash 모델 통합
- 이미지 분석 프롬프트: 음식/음료/차 JSON 형식 응답
- 이미지 압축: 75% (성능 vs 품질 최적화)
- 정규식 캐싱: JSON 파싱 성능 개선
- API 키: Info.plist에서 `GEMINI_API_KEY` 로드

### SavedRecipe.swift
- SwiftData @Model로 로컬 저장
- 필드: id, foodName, ingredientsJSON, steps, tips, imageData, createdAt

### ProCameraView.swift
- AVFoundation 기반 커스텀 카메라
- 플래시 토글: 자동(⚡) → 켜짐(⚡🔆) → 꺼짐(⚡/)
- 줌: 핀치 제스처 (1.0x ~ 5.0x)
- 캡처: 중앙 하단 큰 버튼

### HomeView.swift
- fullScreenCover로 카메라/갤러리 표시 (전체 화면)
- "음식의 모든 비결" 타이틀
- "AI로 분석하기" 버튼

## 빌드 및 실행

### 프로젝트 생성
```bash
cd /Users/neotolee/workspaces/recipe
/opt/homebrew/bin/xcodegen generate
```

### Xcode 열기
```bash
open RecipeAI.xcodeproj
```

### 시뮬레이터 테스트
1. Xcode에서 iPhone 15 선택
2. Product > Run 클릭

### iPhone 실기기 테스트
1. iPhone 13 Pro 연결
2. Xcode > Settings > Accounts에서 Apple ID 로그인
3. Team ID: MHVVU6XHCC 확인
4. Product > Run 클릭

## API 키 설정

1. `project.yml`의 GEMINI_API_KEY 업데이트
2. `xcodegen generate` 실행
3. Info.plist에 자동 포함

## 코딩 규칙

- 응답: 한국어
- 코드 주석: 한국어 (필요시만)
- UI 텍스트: 한국어
- 이모지: 금지 (명시적 요청 시 제외)

## 주의사항

1. **API 배포**: GEMINI_API_KEY 노출 금지 (환경 변수로 관리)
2. **이미지 최적화**: 75% 압축으로 설정 (0.8 이상 금지)
3. **SwiftData 마이그레이션**: 모델 변경 시 버전 관리 필요
4. **권한**: Info.plist에 카메라/앨범 접근 권한 필수

## 성능 최적화 항목

- 정규식 캐싱 ✓
- 이미지 압축율 최적화 ✓
- API 키 보안 관리 ✓
- MainActor에서 비동기 작업 처리

## GitHub 저장소

https://github.com/Lee-myungsun/RecipeAI

## 문제 해결

### 카메라 미리보기 표시 안 됨
- Xcode > Product > Scheme > Edit Scheme에서 Debug executable 확인
- 시뮬레이터는 실제 카메라 없음 (iPhone 실기기에서 테스트)

### Gemini API 429 오류
- 일일 무료 할당량 초과
- 기다리거나 결제 계정 전환

### JSON 파싱 오류
- Gemini 응답이 완전한 JSON이 아닌지 확인
- 프롬프트 수정 (현재: "정확히 다음 JSON 형식으로만 응답")

## 다음 기능 추가 계획

- [ ] 재료 체크리스트 기능
- [ ] 영양 정보 분석
- [ ] 식재료 공동구매 연동
- [ ] 다국어 지원
- [ ] 음성 지원 (레시피 읽기)
