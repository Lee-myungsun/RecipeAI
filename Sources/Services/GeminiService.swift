import Foundation
import GoogleGenerativeAI
import UIKit

struct Ingredient: Codable {
  let name: String
  let amount: String
}

struct RecipeResult: Codable {
  let foodName: String
  let ingredients: [Ingredient]
  let steps: [String]
  let tips: String?
}

@MainActor
class GeminiService {
  private let model: GenerativeModel
  private static let jsonRegex = try? NSRegularExpression(pattern: "\\{[\\s\\S]*\\}")

  init() {
    guard let apiKey = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String else {
      fatalError("GEMINI_API_KEY를 Info.plist에 설정해주세요")
    }
    model = GenerativeModel(name: "gemini-2.0-flash", apiKey: apiKey)
  }

  func analyzeFood(image: UIImage) async throws -> RecipeResult {
    guard let imageData = image.jpegData(compressionQuality: 0.75) else {
      print("❌ 이미지 변환 실패")
      throw RecipeError.invalidImage
    }
    guard imageData.count > 0 else {
      print("❌ 이미지 데이터 크기: 0")
      throw RecipeError.invalidImage
    }

    print("✅ 이미지 크기: \(imageData.count / 1024)KB")

    let prompt = """
    이 이미지를 분석해서 정확히 다음 JSON 형식으로만 응답해주세요 (다른 텍스트 없이):
    {
      "foodName": "음식/음료/차 이름",
      "ingredients": [{"name": "재료명", "amount": "분량"}],
      "steps": ["만드는 단계1", "만드는 단계2"],
      "tips": "더 맛있게 만드는 팁 또는 null"
    }
    음식, 음료, 차, 커피, 주스, 스무디 등 모든 종류의 이미지를 분석할 수 있습니다.
    """

    do {
      print("🔄 Gemini API 호출 중...")
      let response = try await model.generateContent(
        prompt,
        image
      )
      print("✅ Gemini 응답 수신")

      guard let text = response.text else {
        print("❌ Gemini 응답이 비어있음")
        throw RecipeError.noResponse
      }

      print("📄 응답 길이: \(text.count)자")

      let jsonData = try extractJSON(from: text)
      let result = try JSONDecoder().decode(RecipeResult.self, from: jsonData)
      print("✅ JSON 파싱 완료: \(result.foodName)")
      return result
    } catch let error as NSError {
      print("❌ Gemini API 오류: \(error.domain) / \(error.code)")
      print("   오류 설명: \(error.localizedDescription)")
      if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
        print("   하위 오류: \(underlyingError.localizedDescription)")
      }
      throw RecipeError.apiError(error.localizedDescription)
    } catch let error as DecodingError {
      print("❌ JSON 디코딩 오류: \(error)")
      throw RecipeError.decodingError(error)
    } catch {
      print("❌ 예상치 못한 오류: \(error)")
      throw error
    }
  }

  private func extractJSON(from text: String) throws -> Data {
    guard let regex = Self.jsonRegex else {
      throw RecipeError.parsingError("JSON 정규식 생성 실패")
    }

    let nsText = text as NSString
    let range = NSRange(location: 0, length: nsText.length)

    guard let match = regex.firstMatch(in: text, range: range) else {
      throw RecipeError.parsingError("JSON을 찾을 수 없습니다")
    }

    let jsonString = nsText.substring(with: match.range)
    guard let jsonData = jsonString.data(using: .utf8) else {
      throw RecipeError.parsingError("JSON 인코딩 실패")
    }

    return jsonData
  }
}

enum RecipeError: LocalizedError {
  case invalidImage
  case noResponse
  case parsingError(String)
  case decodingError(DecodingError)
  case apiError(String)

  var errorDescription: String? {
    switch self {
    case .invalidImage:
      return "이미지를 처리할 수 없습니다. 사진을 다시 촬영해주세요."
    case .noResponse:
      return "AI 응답이 없습니다. 네트워크를 확인하고 다시 시도해주세요."
    case .parsingError(let msg):
      return "분석 결과 처리 실패: \(msg)"
    case .decodingError(let error):
      return "분석 결과 해석 실패: \(error.localizedDescription)"
    case .apiError(let msg):
      return "AI 분석 실패: \(msg)\n\n확인할 사항:\n1. 네트워크 연결 확인\n2. 올바른 사진인지 확인\n3. 앱을 재시작하고 다시 시도"
    }
  }
}
