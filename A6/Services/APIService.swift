// APIService.swift
// A6 - Network Layer
// Q++RS Ultimate API Integration
// GHOST PROTOCOL: Network Layer

import Foundation

final class APIService {
    static let shared = APIService()
    
    private let baseURL: String
    private let session: URLSession
    
    private init() {
        // Configure base URL - update for production
        self.baseURL = "https://your-replit-app.replit.app"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Code Generation
    
    func generateCode(prompt: String, framework: String) async throws -> String {
        let endpoint = "\(baseURL)/api/generate"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "framework": framework.lowercased(),
            "prompt": prompt,
            "styling": "tailwind"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        let decoded = try JSONDecoder().decode(GenerateResponse.self, from: data)
        return decoded.code
    }
    
    // MARK: - History
    
    func fetchHistory() async throws -> [Generation] {
        let endpoint = "\(baseURL)/api/generations"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        let decoded = try JSONDecoder().decode([GenerationDTO].self, from: data)
        return decoded.map { dto in
            Generation(
                id: dto.id,
                framework: dto.framework,
                prompt: dto.prompt,
                code: dto.code,
                createdAt: ISO8601DateFormatter().date(from: dto.createdAt) ?? Date()
            )
        }
    }
    
    // MARK: - Q++RS Transpiler
    
    func transpileQpprs(code: String) async throws -> TranspileResult {
        let endpoint = "\(baseURL)/api/qpprs/transpile"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["code": code]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        return try JSONDecoder().decode(TranspileResult.self, from: data)
    }
    
    // MARK: - Stats
    
    func fetchStats() async throws -> Stats {
        let endpoint = "\(baseURL)/api/stats"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        return try JSONDecoder().decode(Stats.self, from: data)
    }
    
    // MARK: - Ghost Protocol API
    
    func fetchUsers(requesterId: String) async throws -> [GhostUser] {
        let endpoint = "\(baseURL)/api/admin/users?requesterId=\(requesterId)"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        return try JSONDecoder().decode([GhostUser].self, from: data)
    }
    
    func updateUserRole(userId: String, isAdmin: Bool) async throws -> GhostUser {
        let endpoint = "\(baseURL)/api/admin/users/\(userId)/role"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["isAdmin": isAdmin]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        return try JSONDecoder().decode(GhostUser.self, from: data)
    }
    
    func fetchCognitiveState() async throws -> CognitiveState {
        let endpoint = "\(baseURL)/api/admin/cognitive/state"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        return try JSONDecoder().decode(CognitiveState.self, from: data)
    }
    
    func fetchCognitiveMetrics() async throws -> [CognitiveMetric] {
        let endpoint = "\(baseURL)/api/admin/cognitive/metrics"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        return try JSONDecoder().decode([CognitiveMetric].self, from: data)
    }
    
    func triggerCognitiveAnalysis() async throws -> CognitiveAnalysis {
        let endpoint = "\(baseURL)/api/admin/cognitive/analyze"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
        
        return try JSONDecoder().decode(CognitiveAnalysis.self, from: data)
    }
}

// MARK: - Error Types

enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    case networkError
    case unauthorized
    case forbidden
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError: return "Server error occurred"
        case .decodingError: return "Failed to decode response"
        case .networkError: return "Network connection failed"
        case .unauthorized: return "Unauthorized access"
        case .forbidden: return "Access forbidden - Ghost Protocol active"
        }
    }
}

// MARK: - Response Models

struct GenerateResponse: Codable {
    let code: String
    let filename: String
    let id: Int
}

struct GenerationDTO: Codable {
    let id: Int
    let framework: String
    let prompt: String
    let code: String
    let createdAt: String
}

struct TranspileResult: Codable {
    let swift: String
    let quantumRuntime: String
    let xcodeProject: String
}

struct Stats: Codable {
    let totalGenerations: Int
    let frameworkBreakdown: [String: Int]
    let recentGenerations: Int
}

// MARK: - Ghost Protocol Models

struct CognitiveState: Codable {
    let isHealthy: Bool
    let memoryUsage: Double
    let cpuLoad: Double
    let uptime: Double
    let lastAnalysis: String?
}

struct CognitiveMetric: Codable, Identifiable {
    let id: String
    let timestamp: String
    let memoryUsage: Double
    let cpuLoad: Double
    let errorCount: Int
    let requestCount: Int
}

struct CognitiveAnalysis: Codable {
    let summary: String
    let insights: [String]
    let recommendations: [String]
    let riskLevel: String
}
