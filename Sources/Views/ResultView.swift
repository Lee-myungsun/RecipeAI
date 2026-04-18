import SwiftUI
import SwiftData

struct ResultView: View {
  @Environment(\.modelContext) var modelContext
  @Environment(\.dismiss) var dismiss

  let result: RecipeResult
  let selectedImage: UIImage?

  @State private var isSaving = false
  @State private var showSuccess = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          // 음식명
          Text(result.foodName)
            .font(.title)
            .fontWeight(.bold)

          Divider()

          // 이미지
          if let image = selectedImage {
            Image(uiImage: image)
              .resizable()
              .scaledToFill()
              .frame(height: 250)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }

          // 재료
          VStack(alignment: .leading, spacing: 12) {
            Text("재료")
              .font(.headline)

            ForEach(result.ingredients, id: \.name) { ingredient in
              HStack {
                Text("•")
                VStack(alignment: .leading) {
                  Text(ingredient.name)
                    .fontWeight(.medium)
                  Text(ingredient.amount)
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                Spacer()
              }
            }
          }
          .padding()
          .background(Color.gray.opacity(0.1))
          .cornerRadius(12)

          // 조리 방법
          VStack(alignment: .leading, spacing: 12) {
            Text("조리 방법")
              .font(.headline)

            ForEach(Array(result.steps.enumerated()), id: \.offset) { index, step in
              HStack(alignment: .top, spacing: 12) {
                Text("\(index + 1)")
                  .font(.caption)
                  .fontWeight(.bold)
                  .foregroundColor(.white)
                  .frame(width: 24, height: 24)
                  .background(Color.blue)
                  .cornerRadius(12)

                Text(step)
                  .font(.body)

                Spacer()
              }
            }
          }
          .padding()
          .background(Color.gray.opacity(0.1))
          .cornerRadius(12)

          // 팁
          if let tips = result.tips, !tips.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Image(systemName: "lightbulb.fill")
                  .foregroundColor(.yellow)
                Text("팁")
                  .font(.headline)
              }

              Text(tips)
                .font(.body)
                .lineLimit(nil)
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
          }

          // 저장 버튼
          Button(action: saveRecipe) {
            if isSaving {
              ProgressView()
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            } else {
              Text("저장하기")
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(isSaving)
        }
        .padding()
      }
      .navigationTitle("레시피")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: { dismiss() }) {
            HStack {
              Image(systemName: "chevron.left")
              Text("뒤로")
            }
          }
        }
      }
      .alert("저장 완료", isPresented: $showSuccess) {
        Button("확인") {
          dismiss()
        }
      } message: {
        Text("레시피가 저장되었습니다")
      }
    }
  }

  private func saveRecipe() {
    isSaving = true
    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
    let recipe = SavedRecipe(from: result, imageData: imageData)
    modelContext.insert(recipe)

    do {
      try modelContext.save()
      showSuccess = true
    } catch {
      print("저장 실패: \(error)")
      isSaving = false
    }
  }
}

#Preview {
  let sampleResult = RecipeResult(
    foodName: "스파게티 카르보나라",
    ingredients: [
      Ingredient(name: "스파게티", amount: "400g"),
      Ingredient(name: "계란", amount: "2개"),
      Ingredient(name: "베이컨", amount: "200g"),
    ],
    steps: ["물을 끓인다", "스파게티를 넣는다"],
    tips: "계란은 살짝 덜 익게"
  )

  ResultView(result: sampleResult, selectedImage: nil)
    .modelContainer(for: SavedRecipe.self, inMemory: true)
}
