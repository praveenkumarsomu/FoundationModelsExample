//
//  ContentView.swift
//  FoundationModelsExample
//
//  Created by Somu Praveen Kumar on 27/11/25.
//

import SwiftUI
import FoundationModels

let session = LanguageModelSession()

struct ContentView: View {
    @State var content: String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(content)
        }
        .task {
            do {
                content = try await getResponse()
            } catch {
                content = error.localizedDescription
            }
        }
        .padding()
    }
}

func getResponse() async throws -> String {
    return try await session.respond(to: "What's a good name for a trip to Japan? Respond only with a title").content
}

#Preview {
    ContentView()
}
