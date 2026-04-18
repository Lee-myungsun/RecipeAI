import SwiftUI

struct RecipeDetailView: View {
  @Environment(\.dismiss) var dismiss

  let recipe: SavedRecipe

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // 음식명
        Text(recipe.foodName)
          .font(.title)
          .fontWeight(.bold)

        Divider()

        // 이미지
        if let imageData = recipe.imageData,
           let uiImage = UIImage(data: imageData) {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        // 재료
        VStack(alignment: .leading, spacing: 12) {
          Text("재료")
            .font(.headline)

          ForEach(recipe.ingredients, id: \.name) { ingredient in
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

          ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
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
        if let tips = recipe.tips, !tips.isEmpty {
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

        // 저장 날짜
        HStack {
          Image(systemName: "calendar")
            .foregroundColor(.gray)
          Text("저장된 날짜: \(recipe.createdAt.formatted(date: .abbreviated, time: .shortened))")
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)

        Spacer()
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
  }
}

#Preview {
  let sampleRecipe = SavedRecipe(
    from: RecipeResult(
      foodName: "스파게티 카르보나라",
      ingredients: [
        Ingredient(name: "스파게티", amount: "400g"),
        Ingredient(name: "계란", amount: "2개"),
      ],
      steps: ["물을 끓인다", "스파게티를 넣는다"],
      tips: nil
    ),
    imageData: nil
  )

  RecipeDetailView(recipe: sampleRecipe)
}
