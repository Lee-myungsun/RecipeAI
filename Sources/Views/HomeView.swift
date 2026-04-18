import SwiftUI

struct HomeView: View {
  @State private var selectedImage: UIImage?
  @State private var showPhotoPicker = false
  @State private var showCamera = false
  @State private var isAnalyzing = false
  @State private var result: RecipeResult?
  @State private var showResult = false
  @State private var errorMessage: String?
  @State private var showError = false

  private let geminiService = GeminiService()

  var body: some View {
    VStack(spacing: 20) {
        if let image = selectedImage {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding()
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        } else {
          ZStack {
            LinearGradient(
              gradient: Gradient(colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.1)
              ]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 16) {
              Image(systemName: "camera.aperture")
                .font(.system(size: 56))
                .foregroundColor(.blue)

              VStack(spacing: 8) {
                Text("음식의 모든 비결")
                  .font(.system(size: 20, weight: .semibold))
                  .foregroundColor(.primary)

                Text("사진 하나로 재료, 조리법, 팁까지\n한눈에 알아보세요")
                  .font(.system(size: 14, weight: .regular))
                  .foregroundColor(.gray)
                  .multilineTextAlignment(.center)
              }
            }
            .padding(.vertical, 32)
          }
          .frame(height: 320)
          .padding()
          .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
        }

        HStack(spacing: 12) {
          Button(action: { showPhotoPicker = true }) {
            HStack(spacing: 8) {
              Image(systemName: "photo.stack.fill")
              Text("갤러리")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
          }

          Button(action: { showCamera = true }) {
            HStack(spacing: 8) {
              Image(systemName: "camera.fill")
              Text("카메라")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.15))
            .foregroundColor(.blue)
            .cornerRadius(10)
          }
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showPhotoPicker) {
          PHPickerView(selectedImage: $selectedImage)
        }

        if selectedImage != nil {
          Button(action: analyzeFood) {
            if isAnalyzing {
              HStack(spacing: 8) {
                ProgressView()
                  .tint(.white)
                Text("분석 중...")
              }
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(
                LinearGradient(
                  gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .foregroundColor(.white)
              .cornerRadius(12)
            } else {
              HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("AI로 분석하기")
              }
              .font(.system(size: 16, weight: .semibold))
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(
                LinearGradient(
                  gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .foregroundColor(.white)
              .cornerRadius(12)
            }
          }
          .disabled(isAnalyzing)
          .padding(.horizontal)
        }

        Spacer()
      }
      .fullScreenCover(isPresented: $showCamera) {
        ProCameraView(capturedImage: $selectedImage)
      }
      .sheet(isPresented: $showResult) {
        if let result = result {
          ResultView(result: result, selectedImage: selectedImage)
        }
      }
      .alert("오류", isPresented: $showError, presenting: errorMessage) { _ in
        Button("확인") { }
      } message: { msg in
        Text(msg)
      }
  }


  private func analyzeFood() {
    guard let image = selectedImage else { return }
    isAnalyzing = true

    Task {
      do {
        let recipeResult = try await geminiService.analyzeFood(image: image)
        self.result = recipeResult
        self.showResult = true
      } catch {
        errorMessage = error.localizedDescription
        showError = true
      }
      isAnalyzing = false
    }
  }
}

#Preview {
  HomeView()
}
