// BiometricAuthView.swift
// A6 - Biometric Authentication UI
// Face ID / Touch ID lock screen

import SwiftUI

struct BiometricAuthView: View {
    @StateObject private var authManager = BiometricAuthManager.shared
    @State private var showingRetry = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0d0d14"), Color(hex: "1a1a2e"), Color(hex: "0d0d14")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                logoSection
                
                biometricIcon
                
                instructionText
                
                if let error = authManager.authError {
                    errorMessage(error)
                }
                
                Spacer()
                
                unlockButton
                
                Spacer().frame(height: 40)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                authManager.authenticate()
            }
        }
    }
    
    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "1DE0C2"), Color(hex: "0ea5e9")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .opacity(pulseAnimation ? 0.5 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1DE0C2"), Color(hex: "0ea5e9")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text("A6")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
            }
            .onAppear {
                pulseAnimation = true
            }
            
            Text("SOVEREIGN RUNTIME")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(hex: "1DE0C2"))
                .tracking(4)
        }
    }
    
    private var biometricIcon: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "1a1a2e"))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .stroke(Color(hex: "1DE0C2").opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                if authManager.isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1DE0C2")))
                        .scaleEffect(2)
                } else {
                    Image(systemName: authManager.biometricType.icon)
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "1DE0C2"))
                }
            }
            
            Text(authManager.biometricType.displayName)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
    
    private var instructionText: some View {
        VStack(spacing: 8) {
            Text("Authentication Required")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Use \(authManager.biometricType.displayName) to unlock A6")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    private func errorMessage(_ error: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var unlockButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            authManager.authenticate()
        }) {
            HStack(spacing: 12) {
                Image(systemName: authManager.biometricType.icon)
                    .font(.title3)
                
                Text("Unlock with \(authManager.biometricType.displayName)")
                    .font(.headline)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "1DE0C2"), Color(hex: "0ea5e9")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(authManager.isAuthenticating)
        .opacity(authManager.isAuthenticating ? 0.6 : 1.0)
    }
}

#Preview {
    BiometricAuthView()
}
