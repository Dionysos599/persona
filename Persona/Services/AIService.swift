import Foundation
import SwiftData

// MARK: - Request DTOs

struct ChatRequest: Encodable {
    let model: String
    let messages: [APIMessage]
    let stream: Bool
    let temperature: Double
    let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, stream, temperature
        case maxTokens = "max_tokens"
    }
}

struct APIMessage: Codable {
    let role: String  // "system", "user", "assistant"
    let content: String
}

// MARK: - Response DTOs

struct ChatResponse: Decodable {
    let id: String
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: APIMessage
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
}

struct StreamChunk: Decodable {
    let choices: [StreamChoice]
    
    struct StreamChoice: Decodable {
        let delta: Delta
        
        struct Delta: Decodable {
            let content: String?
        }
    }
}

// MARK: - Generated Persona DTO

struct GeneratedPersona {
    let name: String
    let traits: [String]
    let backstory: String
    let interests: [String]
}

private struct GeneratedPersonaJSON: Decodable {
    let name: String
    let traits: [String]
    let backstory: String
    let interests: [String]
}

// MARK: - Errors

enum AIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case noAPIKey
    case invalidJSON
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from AI service"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .noAPIKey:
            return "API key not configured"
        case .invalidJSON:
            return "Invalid JSON response"
        }
    }
}

// MARK: - AIService

actor AIService {
    static let shared = AIService()
    
    private var apiKey: String = ""
    private var baseURL: URL = URL(string: Constants.API.defaultBaseURL)!
    private var model: String = Constants.API.defaultModel
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.API.requestTimeout
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Configuration
    
    func configure(apiKey: String, baseURL: URL? = nil, model: String? = nil) {
        self.apiKey = apiKey
        if let baseURL = baseURL { self.baseURL = baseURL }
        if let model = model { self.model = model }
    }
    
    // MARK: - Chat (Non-streaming)
    
    func chat(messages: [Message], persona: Persona) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.noAPIKey
        }
        
        let apiMessages = buildAPIMessages(from: messages, persona: persona)
        let request = try buildRequest(messages: apiMessages, stream: false)
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return chatResponse.choices.first?.message.content ?? ""
    }
    
    // MARK: - Chat (Streaming)
    
    func chatStream(messages: [Message], persona: Persona) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    // Get actor state (need await because we're outside actor isolation)
                    let currentAPIKey = await apiKey
                    let currentBaseURL = await baseURL
                    let currentModel = await model
                    
                    guard !currentAPIKey.isEmpty else {
                        continuation.finish(throwing: AIError.noAPIKey)
                        return
                    }
                    
                    // Build request (these methods are synchronous, no await needed)
                    let apiMessages = buildAPIMessages(from: messages, persona: persona)
                    let request = try buildRequest(
                        messages: apiMessages,
                        stream: true,
                        apiKey: currentAPIKey,
                        baseURL: currentBaseURL,
                        model: currentModel
                    )
                    
                    // Make request
                    let (bytes, response) = try await session.bytes(for: request)
                    try validateResponse(response)
                    
                    // Stream response
                    for try await line in bytes.lines {
                        // Parse SSE line (nonisolated method, no await needed)
                        if let content = parseSSELine(line) {
                            continuation.yield(content)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Generate Post Content
    
    func generatePost(for persona: Persona) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.noAPIKey
        }
        
        let prompt = """
        Based on your personality and interests, write a social media post.
        Keep it authentic to your character. The post should be 1-3 sentences.
        Only output the post content, nothing else.
        """
        
        let messages = [
            APIMessage(role: "system", content: persona.systemPrompt),
            APIMessage(role: "user", content: prompt)
        ]
        
        let request = try buildRequest(messages: messages, stream: false)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return chatResponse.choices.first?.message.content ?? ""
    }
    
    // MARK: - Generate Persona
    
    func generatePersona() async throws -> GeneratedPersona {
        guard !apiKey.isEmpty else {
            throw AIError.noAPIKey
        }
        
        let prompt = """
        Create a unique AI persona with the following JSON format:
        {
            "name": "A creative name",
            "traits": ["trait1", "trait2", "trait3"],
            "backstory": "A brief but interesting backstory (2-3 sentences)",
            "interests": ["interest1", "interest2", "interest3"]
        }
        Only output valid JSON, nothing else.
        """
        
        let messages = [
            APIMessage(role: "system", content: "You are a creative assistant that generates unique AI personas."),
            APIMessage(role: "user", content: prompt)
        ]
        
        let request = try buildRequest(messages: messages, stream: false)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        let jsonString = chatResponse.choices.first?.message.content ?? "{}"
        
        // Clean JSON string (remove markdown code blocks if present)
        let cleanedJSON = jsonString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw AIError.invalidJSON
        }
        
        let json = try JSONDecoder().decode(GeneratedPersonaJSON.self, from: jsonData)
        return GeneratedPersona(
            name: json.name,
            traits: json.traits,
            backstory: json.backstory,
            interests: json.interests
        )
    }
    
    // MARK: - Private Helpers
    
    private func buildAPIMessages(from messages: [Message], persona: Persona) -> [APIMessage] {
        var apiMessages = [APIMessage(role: "system", content: persona.systemPrompt)]
        apiMessages += messages.map {
            APIMessage(role: $0.isFromUser ? "user" : "assistant", content: $0.content)
        }
        return apiMessages
    }
    
    private func buildRequest(
        messages: [APIMessage],
        stream: Bool,
        apiKey: String,
        baseURL: URL,
        model: String
    ) throws -> URLRequest {
        let url = baseURL.appendingPathComponent("chat/completions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if stream {
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        }
        
        let body = ChatRequest(
            model: model,
            messages: messages,
            stream: stream,
            temperature: Constants.API.defaultTemperature,
            maxTokens: stream ? nil : Constants.API.defaultMaxTokens
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        return request
    }
    
    private func buildRequest(messages: [APIMessage], stream: Bool) throws -> URLRequest {
        try buildRequest(
            messages: messages,
            stream: stream,
            apiKey: apiKey,
            baseURL: baseURL,
            model: model
        )
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    nonisolated private func parseSSELine(_ line: String) -> String? {
        // SSE format: "data: {json}"
        guard line.hasPrefix("data: "),
              line != "data: [DONE]" else {
            return nil
        }
        
        let jsonString = String(line.dropFirst(6))
        guard let data = jsonString.data(using: .utf8),
              let chunk = try? JSONDecoder().decode(StreamChunk.self, from: data) else {
            return nil
        }
        
        return chunk.choices.first?.delta.content
    }
}

