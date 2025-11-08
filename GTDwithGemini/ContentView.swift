//
//  ContentView.swift
//  GTDwithGemini
//
//  Created by Katie Richman on 11/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var outputText: String = ""
    @State private var isLoading: Bool = false

    private let geminiClient = GeminiClient()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("💡 GTD with Gemini")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 8)

                Text("Ask Gemini to help you get things done — contextually, based on your day.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("What’s on your mind?", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)

                if isLoading {
                    ProgressView("Thinking…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                } else {
                    Button(action: sendToGemini) {
                        Text("Ask Gemini")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Divider()
                    .padding(.vertical, 12)

                ScrollView {
                    Text(outputText.isEmpty ? "Gemini’s response will appear here." : outputText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("GTD with Gemini")
        }
    }

    private func sendToGemini() {
        guard !userInput.isEmpty else { return }
        isLoading = true
        outputText = ""

        geminiClient.ask(userInput) { response in
            DispatchQueue.main.async {
                self.outputText = response
                self.isLoading = false
            }
        }
    }
}
