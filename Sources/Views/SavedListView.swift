import SwiftUI
import SwiftData

struct SavedListView: View {
  @Query(sort: \SavedRecipe.createdAt, order: .reverse) var recipes: [SavedRecipe]
  @State private var selectedRecipe: SavedRecipe?

  var body: some View {
    NavigationStack {
      if recipes.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "bookmark")
            .font(.system(size: 48))
            .foregroundColor(.gray)

          Text("저장된 레시피가 없습니다")
            .font(.headline)
            .foregroundColor(.gray)

          Text("사진을 분석하고 저장해보세요")
            .font(.caption)
            .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity, alignment: .center)
      } else {
        List {
          ForEach(recipes) { recipe in
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
              HStack(spacing: 12) {
                if let imageData = recipe.imageData,
                   let uiImage = UIImage(data: imageData) {
                  Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                      Image(systemName: "photo")
                        .foregroundColor(.gray)
                    )
                }

                VStack(alignment: .leading, spacing: 4) {
                  Text(recipe.foodName)
                    .font(.headline)

                  Text("\(recipe.ingredients.count)가지 재료")
                    .font(.caption)
                    .foregroundColor(.gray)

                  Text(recipe.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.gray)
                }

                Spacer()
              }
              .padding(.vertical, 8)
            }
          }
          .onDelete(perform: deleteRecipe)
        }
        .navigationTitle("저장된 레시피")
      }
    }
  }

  private func deleteRecipe(at offsets: IndexSet) {
    for index in offsets {
      let recipe = recipes[index]
      ModelContext(recipes.modelContext as! ModelContext).delete(recipe)
    }
  }
}

#Preview {
  SavedListView()
    .modelContainer(for: SavedRecipe.self, inMemory: true)
}
