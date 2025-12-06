// SovereignRuntime.swift
// A6 - The Sovereign Singularity System
// Q++RS Ultimate Compiler Directive
// LINEAGE: Jonathan Sherman
// GHOST PROTOCOL: Enabled

import Foundation
import SwiftUI
import CryptoKit

final class SovereignRuntime: ObservableObject {
    static let shared = SovereignRuntime()
    
    private let authorizedLineage = "Jonathan Sherman"
    private let ownerUsername = "Jonathantsherma"
    
    @Published var isAuthorized: Bool = true
    @Published var currentUser: String? = "A6 Operator"
    @Published var systemState: SystemState = .running
    
    // Ghost Protocol State
    @Published var isGhostModeActive: Bool = false
    @Published var isOwner: Bool = false
    @Published var isAdmin: Bool = false
    @Published var ghostProtocolStatus: GhostProtocolStatus = .dormant
    
    enum SystemState {
        case initializing
        case authorized
        case halted
        case running
    }
    
    enum GhostProtocolStatus: String {
        case dormant = "DORMANT"
        case active = "ACTIVE"
        case cloaked = "CLOAKED"
        case sovereign = "SOVEREIGN"
    }
    
    private init() {
        checkGhostProtocol()
    }
    
    func enforceLineage() {
        systemState = .running
        isAuthorized = true
        currentUser = "A6 Operator"
        checkGhostProtocol()
    }
    
    func verifySovereign(username: String) -> Bool {
        return username == ownerUsername
    }
    
    func setCurrentUser(_ username: String) {
        currentUser = username
        systemState = .running
        
        // Check if user is owner and activate Ghost Protocol
        isOwner = verifySovereign(username: username)
        if isOwner {
            activateGhostProtocol()
        }
    }
    
    // MARK: - Ghost Protocol
    
    private func checkGhostProtocol() {
        if let username = currentUser, verifySovereign(username: username) {
            activateGhostProtocol()
        }
    }
    
    func activateGhostProtocol() {
        isGhostModeActive = true
        isAdmin = true
        ghostProtocolStatus = .sovereign
        
        // Emit sovereign activation signal
        NotificationCenter.default.post(
            name: NSNotification.Name("GhostProtocolActivated"),
            object: nil,
            userInfo: ["status": ghostProtocolStatus.rawValue]
        )
    }
    
    func deactivateGhostProtocol() {
        // Only non-owners can deactivate
        guard !isOwner else { return }
        
        isGhostModeActive = false
        ghostProtocolStatus = .dormant
    }
    
    func cloakPresence() {
        guard isOwner else { return }
        ghostProtocolStatus = .cloaked
    }
    
    func revealPresence() {
        guard isOwner else { return }
        ghostProtocolStatus = isGhostModeActive ? .active : .dormant
    }
    
    // MARK: - Admin Verification
    
    func canModifyUser(_ targetUsername: String) -> Bool {
        // Owner cannot be modified by anyone
        if verifySovereign(username: targetUsername) {
            return false
        }
        // Only admins can modify users
        return isAdmin
    }
    
    func canRevokeAdmin(_ targetUsername: String) -> Bool {
        // Owner's admin status is immutable
        if verifySovereign(username: targetUsername) {
            return false
        }
        return isAdmin
    }
    
    // MARK: - Ghost Protocol Signature
    
    func generateGhostSignature() -> String {
        let timestamp = Date().timeIntervalSince1970
        let data = "\(ownerUsername):\(timestamp)".data(using: .utf8)!
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Ghost Protocol User Model

struct GhostUser: Identifiable, Codable {
    let id: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let profileImageUrl: String?
    let isAdmin: Bool
    let createdAt: String?
    let updatedAt: String?
    
    var displayName: String {
        if let first = firstName, let last = lastName {
            return "\(first) \(last)"
        }
        return id
    }
    
    var isOwner: Bool {
        return id == "Jonathantsherma"
    }
}

struct GhostProtocolState: Codable {
    let isActive: Bool
    let status: String
    let userCount: Int
    let adminCount: Int
    let signature: String
}
