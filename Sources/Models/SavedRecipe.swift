import Foundation
import SwiftData

@Model
final class SavedRecipe {
  @Attribute(.unique) var id: UUID
  var foodName: String
  var ingredientsJSON: Data
  var steps: [String]
  var tips: String?
  var imageData: Data?
  var createdAt: Date

  init(from result: RecipeResult, imageData: Data?) {
    self.id = UUID()
    self.foodName = result.foodName
    self.steps = result.steps
    self.tips = result.tips
    self.imageData = imageData
    self.createdAt = Date()

    let encoder = JSONEncoder()
    self.ingredientsJSON = (try? encoder.encode(result.ingredients)) ?? Data()
  }

  var ingredients: [Ingredient] {
    let decoder = JSONDecoder()
    return (try? decoder.decode([Ingredient].self, from: ingredientsJSON)) ?? []
  }
}
