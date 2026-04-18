import Foundation

struct APIKey {
  static let gemini: String = {
    guard let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] else {
      fatalError("GEMINI_API_KEY 환경변수가 설정되지 않았습니다. Xcode scheme에서 설정해주세요.")
    }
    return key
  }()
}
