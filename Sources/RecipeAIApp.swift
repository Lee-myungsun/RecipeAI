import SwiftUI
import SwiftData

@main
struct RecipeAIApp: App {
  let modelContainer: ModelContainer

  init() {
    do {
      modelContainer = try ModelContainer(
        for: SavedRecipe.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: false)
      )
    } catch {
      fatalError("SwiftData 초기화 실패: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      HomeView()
        .modelContainer(modelContainer)
    }
  }
}
