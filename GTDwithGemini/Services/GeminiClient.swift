//
//  GeminiClient.swift
//  GTDwithGemini
//
//  Created by Katie Richman on 11/8/25.
//

import Foundation

final class GeminiClient {
    private let apiKey: String

    init() {
        // Pull the API key from the environment (set by Secrets.xcconfig)
        if let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !key.isEmpty {
            self.apiKey = key
        } else {
            print("⚠️ Warning: Missing GEMINI_API_KEY in environment variables.")
            self.apiKey = "MISSING_API_KEY"
        }
    }

    func ask(_ prompt: String, completion: @escaping (String) -> Void) {
        guard apiKey != "MISSING_API_KEY" else {
            completion("Error: Missing API key.")
            return
        }

        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
            completion("Error: Invalid Gemini API URL.")
            return
        }

        let body: [String: Any] = [
            "contents": [
                ["role": "user", "parts": [["text": prompt]]]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion("Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("Error: No data received from Gemini API.")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let first = candidates.first,
                   let content = first["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    let raw = String(data: data, encoding: .utf8) ?? "Unknown"
                    completion("Unexpected response: \(raw)")
                }
            } catch {
                completion("Decoding error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
}
