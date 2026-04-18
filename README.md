# RecipeAI

AI 음식/음료 분석 앱. 사진 하나로 재료, 조리법, 팁까지 한번에!

## 기능

- **AI 분석**: Google Gemini 2.0 Flash로 음식/음료/차 이미지 분석
- **재료 리스트**: 각 재료의 분량과 함께 표시
- **단계별 조리법**: 요리하는 방법을 단계별로 설명
- **전문가 팁**: 더 맛있게 만드는 팁 제공
- **카메라 기능**: 플래시 제어, 줌(1x ~ 5x) 기능
- **갤러리**: 앨범에서 사진 선택
- **로컬 저장**: SwiftData를 사용한 레시피 저장 및 관리
- **저장된 레시피 목록**: 이전에 분석한 레시피 조회

## 기술 스택

- **UI**: SwiftUI
- **프로젝트**: XcodeGen
- **AI**: Google Gemini 2.0 Flash
- **DB**: SwiftData (iOS 17+)
- **사진**: PhotosUI, AVFoundation
- **최소 iOS**: 17.0

## 구조

```
Sources/
├── RecipeAIApp.swift           # 앱 엔트리 포인트
├── Models/
│   └── SavedRecipe.swift       # SwiftData 모델
├── Services/
│   └── GeminiService.swift     # Gemini API 통합
└── Views/
    ├── HomeView.swift          # 메인 화면
    ├── ResultView.swift        # 분석 결과
    ├── SavedListView.swift     # 저장된 레시피 목록
    ├── RecipeDetailView.swift  # 레시피 상세보기
    ├── ProCameraView.swift     # 카메라 (AVFoundation)
    └── PHPickerView.swift      # 갤러리 (PhotosUI)
```

## 사용 방법

1. 앱 실행
2. 카메라로 촬영 또는 갤러리에서 선택
3. "AI로 분석하기" 버튼 클릭
4. 분석된 재료, 조리법, 팁 확인
5. "저장하기"로 나중에 다시 볼 수 있게 저장

## 빌드 및 실행

```bash
xcodegen generate
open RecipeAI.xcodeproj
```

## 최적화

- 이미지 압축율: 75% (성능 vs 품질 균형)
- 정규식 캐싱: JSON 파싱 성능 개선
- API 키: Info.plist에서 보안 관리

## 라이선스

MIT
