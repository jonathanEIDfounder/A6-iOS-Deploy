// SettingsView.swift
// A6 - Settings & Preferences
// iPhone XR Native

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var runtime: SovereignRuntime
    @StateObject private var biometricAuth = BiometricAuthManager.shared
    @State private var isDarkMode = true
    @State private var enableNotifications = true
    @State private var defaultFramework = "React"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    userSection
                    securitySection
                    preferencesSection
                    sovereignSection
                    aboutSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var securitySection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { biometricAuth.isBiometricEnabled },
                set: { enabled in
                    biometricAuth.setBiometricEnabled(enabled)
                }
            )) {
                HStack(spacing: 12) {
                    Image(systemName: biometricAuth.biometricType.icon)
                        .font(.title3)
                        .foregroundColor(Color(hex: "1DE0C2"))
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(biometricAuth.biometricType.displayName)
                            .foregroundColor(.white)
                        
                        Text("Require authentication to unlock app")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .tint(Color(hex: "1DE0C2"))
            .listRowBackground(Color(hex: "1a1a2e"))
            
            if biometricAuth.isBiometricEnabled {
                HStack {
                    Label("Lock on Background", systemImage: "lock.rotation")
                        .foregroundColor(.white)
                    Spacer()
                    Text("Enabled")
                        .font(.caption)
                        .foregroundColor(Color(hex: "1DE0C2"))
                }
                .listRowBackground(Color(hex: "1a1a2e"))
            }
        } header: {
            Text("Security")
                .foregroundColor(.gray)
        } footer: {
            Text("When enabled, \(biometricAuth.biometricType.displayName) will be required to access the app. The app will lock when sent to background.")
                .foregroundColor(.gray)
        }
    }
    
    private var userSection: some View {
        Section {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "1DE0C2"), Color(hex: "0ea5e9")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(runtime.currentUser?.prefix(1).uppercased() ?? "A")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(runtime.currentUser ?? "A6 User")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Sovereign Operator")
                        .font(.caption)
                        .foregroundColor(Color(hex: "1DE0C2"))
                }
                
                Spacer()
            }
            .listRowBackground(Color(hex: "1a1a2e"))
        } header: {
            Text("Account")
                .foregroundColor(.gray)
        }
    }
    
    private var preferencesSection: some View {
        Section {
            Toggle(isOn: $isDarkMode) {
                Label("Dark Mode", systemImage: "moon.fill")
                    .foregroundColor(.white)
            }
            .tint(Color(hex: "1DE0C2"))
            .listRowBackground(Color(hex: "1a1a2e"))
            
            Toggle(isOn: $enableNotifications) {
                Label("Notifications", systemImage: "bell.fill")
                    .foregroundColor(.white)
            }
            .tint(Color(hex: "1DE0C2"))
            .listRowBackground(Color(hex: "1a1a2e"))
            
            Picker(selection: $defaultFramework) {
                Text("React").tag("React")
                Text("Vue").tag("Vue")
                Text("SwiftUI").tag("SwiftUI")
                Text("Flutter").tag("Flutter")
                Text("Q++RS").tag("Q++RS")
            } label: {
                Label("Default Framework", systemImage: "square.stack.3d.up")
                    .foregroundColor(.white)
            }
            .listRowBackground(Color(hex: "1a1a2e"))
        } header: {
            Text("Preferences")
                .foregroundColor(.gray)
        }
    }
    
    private var sovereignSection: some View {
        Section {
            HStack {
                Label("Lineage", systemImage: "shield.checkered")
                    .foregroundColor(.white)
                Spacer()
                Text("Jonathan Sherman")
                    .foregroundColor(Color(hex: "1DE0C2"))
            }
            .listRowBackground(Color(hex: "1a1a2e"))
            
            HStack {
                Label("Runtime", systemImage: "cpu")
                    .foregroundColor(.white)
                Spacer()
                Text("Q++RS v1.0")
                    .foregroundColor(.gray)
            }
            .listRowBackground(Color(hex: "1a1a2e"))
            
            HStack {
                Label("Protocol", systemImage: "lock.shield")
                    .foregroundColor(.white)
                Spacer()
                Text("One-Warning")
                    .foregroundColor(.orange)
            }
            .listRowBackground(Color(hex: "1a1a2e"))
        } header: {
            Text("Sovereign Runtime")
                .foregroundColor(.gray)
        }
    }
    
    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                    .foregroundColor(.white)
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.gray)
            }
            .listRowBackground(Color(hex: "1a1a2e"))
            
            HStack {
                Label("Build", systemImage: "hammer")
                    .foregroundColor(.white)
                Spacer()
                Text("2024.12.06")
                    .foregroundColor(.gray)
            }
            .listRowBackground(Color(hex: "1a1a2e"))
            
            HStack {
                Label("Device", systemImage: "iphone")
                    .foregroundColor(.white)
                Spacer()
                Text("iPhone XR")
                    .foregroundColor(.gray)
            }
            .listRowBackground(Color(hex: "1a1a2e"))
        } header: {
            Text("About")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SovereignRuntime.shared)
}
