// BiometricAuthManager.swift
// A6 - Biometric Authentication (Face ID / Touch ID)
// Secure app access with biometric verification

import Foundation
import LocalAuthentication
import SwiftUI

class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var isAuthenticating: Bool = false
    @Published var authError: String?
    @Published var biometricType: BiometricType = .none
    @Published var isBiometricEnabled: Bool = true
    
    enum BiometricType {
        case none
        case touchID
        case faceID
        
        var icon: String {
            switch self {
            case .none: return "lock.fill"
            case .touchID: return "touchid"
            case .faceID: return "faceid"
            }
        }
        
        var displayName: String {
            switch self {
            case .none: return "Passcode"
            case .touchID: return "Touch ID"
            case .faceID: return "Face ID"
            }
        }
    }
    
    enum AuthError: Error, LocalizedError {
        case biometryNotAvailable
        case biometryNotEnrolled
        case biometryLockout
        case userCancel
        case userFallback
        case systemCancel
        case invalidContext
        case notInteractive
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .biometryNotAvailable:
                return "Biometric authentication is not available on this device"
            case .biometryNotEnrolled:
                return "No biometric data is enrolled. Please set up Face ID or Touch ID in Settings"
            case .biometryLockout:
                return "Biometric authentication is locked. Please use your passcode"
            case .userCancel:
                return "Authentication was cancelled"
            case .userFallback:
                return "User chose to use passcode"
            case .systemCancel:
                return "Authentication was cancelled by the system"
            case .invalidContext:
                return "Authentication context is invalid"
            case .notInteractive:
                return "Device is not in interactive mode"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
    
    private init() {
        loadSettings()
        checkBiometricType()
    }
    
    private func loadSettings() {
        if let enabled = UserDefaults.standard.object(forKey: "biometricAuthEnabled") as? Bool {
            isBiometricEnabled = enabled
        } else {
            isBiometricEnabled = true
            UserDefaults.standard.set(true, forKey: "biometricAuthEnabled")
        }
    }
    
    func setBiometricEnabled(_ enabled: Bool) {
        isBiometricEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "biometricAuthEnabled")
        
        if !enabled {
            isAuthenticated = true
        } else {
            lockApp()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.authenticate()
            }
        }
    }
    
    func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
            case .opticID:
                biometricType = .faceID
            case .none:
                biometricType = .none
            @unknown default:
                biometricType = .none
            }
        } else {
            biometricType = .none
        }
    }
    
    func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate(reason: String = "Authenticate to access A6") {
        guard isBiometricEnabled else {
            isAuthenticated = true
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = "Use Passcode"
        
        isAuthenticating = true
        authError = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, evaluateError in
                DispatchQueue.main.async {
                    self?.isAuthenticating = false
                    
                    if success {
                        self?.isAuthenticated = true
                        self?.authError = nil
                        
                        NotificationCenter.default.post(
                            name: NSNotification.Name("BiometricAuthSuccess"),
                            object: nil
                        )
                    } else {
                        self?.handleAuthError(evaluateError)
                    }
                }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, evaluateError in
                DispatchQueue.main.async {
                    self?.isAuthenticating = false
                    
                    if success {
                        self?.isAuthenticated = true
                        self?.authError = nil
                    } else {
                        self?.handleAuthError(evaluateError)
                    }
                }
            }
        } else {
            isAuthenticating = false
            if let laError = error {
                handleAuthError(laError)
            } else {
                isAuthenticated = true
            }
        }
    }
    
    private func handleAuthError(_ error: Error?) {
        guard let laError = error as? LAError else {
            authError = AuthError.unknown.localizedDescription
            return
        }
        
        switch laError.code {
        case .biometryNotAvailable:
            authError = AuthError.biometryNotAvailable.localizedDescription
        case .biometryNotEnrolled:
            authError = AuthError.biometryNotEnrolled.localizedDescription
        case .biometryLockout:
            authenticateWithPasscode(reason: "Biometric locked. Enter passcode to access A6")
        case .userCancel:
            authError = AuthError.userCancel.localizedDescription
        case .userFallback:
            authenticateWithPasscode(reason: "Enter passcode to access A6")
        case .systemCancel:
            authError = AuthError.systemCancel.localizedDescription
        case .invalidContext:
            authError = AuthError.invalidContext.localizedDescription
        case .notInteractive:
            authError = AuthError.notInteractive.localizedDescription
        default:
            authError = AuthError.unknown.localizedDescription
        }
    }
    
    func authenticateWithPasscode(reason: String = "Enter passcode to access A6") {
        let context = LAContext()
        var error: NSError?
        
        isAuthenticating = true
        authError = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, evaluateError in
                DispatchQueue.main.async {
                    self?.isAuthenticating = false
                    
                    if success {
                        self?.isAuthenticated = true
                        self?.authError = nil
                        
                        NotificationCenter.default.post(
                            name: NSNotification.Name("BiometricAuthSuccess"),
                            object: nil
                        )
                    } else if let laError = evaluateError as? LAError {
                        switch laError.code {
                        case .userCancel:
                            self?.authError = AuthError.userCancel.localizedDescription
                        case .systemCancel:
                            self?.authError = AuthError.systemCancel.localizedDescription
                        default:
                            self?.authError = AuthError.unknown.localizedDescription
                        }
                    }
                }
            }
        } else {
            isAuthenticating = false
            isAuthenticated = true
        }
    }
    
    func lockApp() {
        isAuthenticated = false
        authError = nil
    }
    
    func resetAuthentication() {
        isAuthenticated = false
        isAuthenticating = false
        authError = nil
    }
}
