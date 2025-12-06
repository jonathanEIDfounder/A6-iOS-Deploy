// PrivacyShieldManager.swift
// A6 - Device Privacy Protection
// Prevents screen capture, recording, and mirroring

import SwiftUI
import UIKit

class PrivacyShieldManager: ObservableObject {
    static let shared = PrivacyShieldManager()
    
    @Published var isShieldActive: Bool = true
    @Published var isCaptureDetected: Bool = false
    @Published var isMirroringDetected: Bool = false
    
    private var secureTextField: UITextField?
    private var observers: [NSObjectProtocol] = []
    
    private init() {
        setupScreenCaptureDetection()
        setupMirroringDetection()
    }
    
    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    // MARK: - Screen Capture Detection
    
    private func setupScreenCaptureDetection() {
        let captureObserver = NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleCaptureChange()
        }
        observers.append(captureObserver)
        
        // Check initial state
        handleCaptureChange()
    }
    
    private func handleCaptureChange() {
        isCaptureDetected = UIScreen.main.isCaptured
        if isCaptureDetected && isShieldActive {
            triggerPrivacyAlert(type: .capture)
        }
    }
    
    // MARK: - Screen Mirroring Detection
    
    private func setupMirroringDetection() {
        let screenObserver = NotificationCenter.default.addObserver(
            forName: UIScreen.didConnectNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkMirroring()
        }
        observers.append(screenObserver)
        
        let disconnectObserver = NotificationCenter.default.addObserver(
            forName: UIScreen.didDisconnectNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkMirroring()
        }
        observers.append(disconnectObserver)
        
        checkMirroring()
    }
    
    private func checkMirroring() {
        isMirroringDetected = UIScreen.screens.count > 1
        if isMirroringDetected && isShieldActive {
            triggerPrivacyAlert(type: .mirroring)
        }
    }
    
    // MARK: - Privacy Alerts
    
    enum PrivacyThreatType {
        case capture
        case mirroring
        case screenshot
        
        var title: String {
            switch self {
            case .capture: return "Screen Recording Detected"
            case .mirroring: return "Screen Mirroring Detected"
            case .screenshot: return "Screenshot Blocked"
            }
        }
        
        var message: String {
            switch self {
            case .capture: return "Your screen is being recorded. Privacy shield activated."
            case .mirroring: return "External display detected. Content hidden for your security."
            case .screenshot: return "Screenshots are disabled for privacy."
            }
        }
    }
    
    private func triggerPrivacyAlert(type: PrivacyThreatType) {
        DispatchQueue.main.async {
            // Post notification for UI to respond
            NotificationCenter.default.post(
                name: .privacyThreatDetected,
                object: type
            )
        }
    }
    
    // MARK: - Shield Controls
    
    func enableShield() {
        isShieldActive = true
        handleCaptureChange()
        checkMirroring()
    }
    
    func disableShield() {
        isShieldActive = false
    }
    
    var shouldHideContent: Bool {
        return isShieldActive && (isCaptureDetected || isMirroringDetected)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let privacyThreatDetected = Notification.Name("privacyThreatDetected")
}

// MARK: - Privacy Shield View Modifier

struct PrivacyShieldModifier: ViewModifier {
    @ObservedObject var privacyManager = PrivacyShieldManager.shared
    @State private var showAlert = false
    @State private var alertType: PrivacyShieldManager.PrivacyThreatType = .capture
    
    func body(content: Content) -> some View {
        ZStack {
            if privacyManager.shouldHideContent {
                PrivacyBlockedView()
            } else {
                content
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .privacyThreatDetected)) { notification in
            if let type = notification.object as? PrivacyShieldManager.PrivacyThreatType {
                alertType = type
                showAlert = true
            }
        }
        .alert(alertType.title, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertType.message)
        }
    }
}

// MARK: - Privacy Blocked View

struct PrivacyBlockedView: View {
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                }
                
                Text("PRIVACY SHIELD ACTIVE")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
                
                Text("Content hidden to protect your privacy")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    if PrivacyShieldManager.shared.isCaptureDetected {
                        HStack(spacing: 8) {
                            Image(systemName: "record.circle.fill")
                                .foregroundColor(.red)
                            Text("Screen recording detected")
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 12, design: .monospaced))
                    }
                    
                    if PrivacyShieldManager.shared.isMirroringDetected {
                        HStack(spacing: 8) {
                            Image(systemName: "tv.fill")
                                .foregroundColor(.orange)
                            Text("External display detected")
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 12, design: .monospaced))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
            .padding()
        }
        .onAppear {
            pulseAnimation = true
        }
    }
}

// MARK: - View Extension

extension View {
    func privacyShield() -> some View {
        modifier(PrivacyShieldModifier())
    }
}

// MARK: - Secure Window Helper

class SecureWindowHelper {
    static func makeWindowSecure(_ window: UIWindow?) {
        guard let window = window else { return }
        
        let field = UITextField()
        field.isSecureTextEntry = true
        window.addSubview(field)
        field.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        field.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        window.layer.superlayer?.addSublayer(field.layer)
        field.layer.sublayers?.first?.addSublayer(window.layer)
    }
}
