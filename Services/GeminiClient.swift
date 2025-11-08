import Foundation

class GeminiClient {
    static let shared = GeminiClient()
    private let apiKey = "AIzaSyB9CetMqrckLtBGOvOhLl6R0KUgevb991o"

    func askGemini(prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(apiKey)") else {
            completion("Invalid URL")
            return
        }

        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    completion(text)
                } else {
                    completion("No valid response from Gemini")
                }
            } catch {
                completion("Failed to decode response: \(error.localizedDescription)")
            }
        }.resume()
    }
}
