import SwiftUI
import PhotosUI

struct HomeView: View {
  @State private var selectedImage: UIImage?
  @State private var photoItem: PhotosPickerItem?
  @State private var showCamera = false
  @State private var isAnalyzing = false
  @State private var result: RecipeResult?
  @State private var showResult = false
  @State private var errorMessage: String?
  @State private var showError = false

  private let geminiService = GeminiService()

  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        if let image = selectedImage {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        } else {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
            .frame(height: 300)
            .overlay(
              VStack(spacing: 8) {
                Image(systemName: "photo")
                  .font(.system(size: 48))
                  .foregroundColor(.gray)
                Text("음식 사진을 선택하세요")
                  .font(.headline)
                  .foregroundColor(.gray)
              }
            )
            .padding()
        }

        HStack(spacing: 12) {
          PhotosPicker(
            selection: $photoItem,
            matching: .images,
            label: {
              Label("갤러리", systemImage: "photo.stack")
                .frame(maxWidth: .infinity)
            }
          )
          .buttonStyle(.bordered)
          .onChange(of: photoItem) { _, newItem in
            Task {
              if let data = try await newItem?.loadTransferable(type: Data.self),
                 let image = UIImage(data: data) {
                selectedImage = image
              }
            }
          }

          Button(action: { showCamera = true }) {
            Label("카메라", systemImage: "camera.fill")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
        }
        .padding(.horizontal)

        if selectedImage != nil {
          Button(action: analyzeFood) {
            if isAnalyzing {
              ProgressView()
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            } else {
              Text("분석하기")
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(isAnalyzing)
          .padding(.horizontal)
        }

        Spacer()
      }
      .navigationTitle("RecipeAI")
      .sheet(isPresented: $showCamera) {
        CameraView(image: $selectedImage)
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
