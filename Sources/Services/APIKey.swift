import Foundation

struct APIKey {
  static let gemini: String = {
    if let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
      return key
    }
    return "AIzaSyDtIAXdagTZ1F553xD53ASMVJaaRbFQpM0"
  }()
}
