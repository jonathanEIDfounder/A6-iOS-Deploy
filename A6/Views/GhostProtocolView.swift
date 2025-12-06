// GhostProtocolView.swift
// A6 - Ghost Protocol Admin Panel
// SOVEREIGN ACCESS ONLY

import SwiftUI

struct GhostProtocolView: View {
    @EnvironmentObject var runtime: SovereignRuntime
    @StateObject private var viewModel = GhostProtocolViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ghostStatusHeader
                        
                        if runtime.isOwner {
                            cognitiveStateCard
                            userManagementSection
                            systemControlsSection
                        } else {
                            accessDeniedView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Ghost Protocol")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refresh()
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private var ghostStatusHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [statusColor.opacity(0.5), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "eye.slash.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(statusColor)
                    .opacity(viewModel.pulseAnimation ? 1.0 : 0.6)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: viewModel.pulseAnimation)
            }
            .onAppear { viewModel.pulseAnimation = true }
            
            Text("GHOST PROTOCOL")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(runtime.ghostProtocolStatus.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(statusColor.opacity(0.15))
            .cornerRadius(20)
        }
    }
    
    private var statusColor: Color {
        switch runtime.ghostProtocolStatus {
        case .sovereign: return Color(hex: "1DE0C2")
        case .active: return Color(hex: "22c55e")
        case .cloaked: return Color(hex: "8b5cf6")
        case .dormant: return Color.gray
        }
    }
    
    private var cognitiveStateCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(Color(hex: "1DE0C2"))
                Text("Cognitive State")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                if viewModel.isLoadingCognitive {
                    ProgressView()
                        .tint(Color(hex: "1DE0C2"))
                }
            }
            
            if let state = viewModel.cognitiveState {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    metricTile(
                        title: "Health",
                        value: state.isHealthy ? "Optimal" : "Degraded",
                        icon: state.isHealthy ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                        color: state.isHealthy ? .green : .red
                    )
                    
                    metricTile(
                        title: "Memory",
                        value: String(format: "%.1f%%", state.memoryUsage),
                        icon: "memorychip",
                        color: state.memoryUsage > 80 ? .orange : Color(hex: "1DE0C2")
                    )
                    
                    metricTile(
                        title: "CPU",
                        value: String(format: "%.1f%%", state.cpuLoad),
                        icon: "cpu",
                        color: state.cpuLoad > 80 ? .orange : Color(hex: "1DE0C2")
                    )
                    
                    metricTile(
                        title: "Uptime",
                        value: formatUptime(state.uptime),
                        icon: "clock.arrow.circlepath",
                        color: Color(hex: "1DE0C2")
                    )
                }
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    viewModel.triggerAnalysis()
                }) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                        Text("Run Analysis")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "1DE0C2").opacity(0.2))
                    .foregroundColor(Color(hex: "1DE0C2"))
                    .cornerRadius(8)
                }
                .disabled(viewModel.isAnalyzing)
                
                if let analysis = viewModel.latestAnalysis {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Latest Analysis")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(analysis.summary)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if !analysis.insights.isEmpty {
                            ForEach(analysis.insights.prefix(3), id: \.self) { insight in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                    Text(insight)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "0d0d14"))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
        )
    }
    
    private func metricTile(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "0d0d14"))
        .cornerRadius(8)
    }
    
    private var userManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(Color(hex: "1DE0C2"))
                Text("User Management")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                if viewModel.isLoadingUsers {
                    ProgressView()
                        .tint(Color(hex: "1DE0C2"))
                }
            }
            
            if viewModel.users.isEmpty && !viewModel.isLoadingUsers {
                Text("No users found")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.users) { user in
                    userRow(user)
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
        )
    }
    
    private func userRow(_ user: GhostUser) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1DE0C2"), Color(hex: "8b5cf6")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(user.displayName.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundColor(.black)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    if user.isOwner {
                        Text("SOVEREIGN")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "1DE0C2"))
                            .cornerRadius(4)
                    } else if user.isAdmin {
                        Text("ADMIN")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "8b5cf6"))
                            .cornerRadius(4)
                    }
                }
                
                if let email = user.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if !user.isOwner && runtime.isOwner {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    viewModel.toggleAdmin(user)
                }) {
                    Image(systemName: user.isAdmin ? "shield.slash" : "shield.fill")
                        .foregroundColor(user.isAdmin ? .red : Color(hex: "1DE0C2"))
                }
            }
        }
        .padding()
        .background(Color(hex: "0d0d14"))
        .cornerRadius(8)
    }
    
    private var systemControlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Color(hex: "1DE0C2"))
                Text("System Controls")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                controlRow(
                    title: "Ghost Cloak",
                    subtitle: "Hide from user lists",
                    icon: "eye.slash",
                    isActive: runtime.ghostProtocolStatus == .cloaked,
                    action: {
                        if runtime.ghostProtocolStatus == .cloaked {
                            runtime.revealPresence()
                        } else {
                            runtime.cloakPresence()
                        }
                    }
                )
                
                controlRow(
                    title: "Signature",
                    subtitle: runtime.generateGhostSignature().prefix(16) + "...",
                    icon: "signature",
                    isActive: true,
                    action: {
                        UIPasteboard.general.string = runtime.generateGhostSignature()
                        let feedback = UINotificationFeedbackGenerator()
                        feedback.notificationOccurred(.success)
                    }
                )
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
        )
    }
    
    private func controlRow(title: String, subtitle: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isActive ? Color(hex: "1DE0C2") : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Circle()
                    .fill(isActive ? Color(hex: "1DE0C2") : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
            .padding()
            .background(Color(hex: "0d0d14"))
            .cornerRadius(8)
        }
    }
    
    private var accessDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("ACCESS DENIED")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("Ghost Protocol requires Sovereign authorization.\nThis incident has been logged.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(16)
    }
    
    private func formatUptime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

class GhostProtocolViewModel: ObservableObject {
    @Published var users: [GhostUser] = []
    @Published var cognitiveState: CognitiveState?
    @Published var latestAnalysis: CognitiveAnalysis?
    @Published var isLoadingUsers = false
    @Published var isLoadingCognitive = false
    @Published var isAnalyzing = false
    @Published var pulseAnimation = false
    @Published var error: String?
    
    private let apiService = APIService.shared
    private let runtime = SovereignRuntime.shared
    
    func loadData() {
        guard runtime.isOwner else { return }
        
        Task {
            await loadUsers()
            await loadCognitiveState()
        }
    }
    
    func refresh() async {
        await loadUsers()
        await loadCognitiveState()
    }
    
    private func loadUsers() async {
        await MainActor.run { isLoadingUsers = true }
        
        do {
            let requesterId = runtime.currentUser ?? ""
            let fetchedUsers = try await apiService.fetchUsers(requesterId: requesterId)
            await MainActor.run {
                self.users = fetchedUsers
                self.isLoadingUsers = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoadingUsers = false
            }
        }
    }
    
    private func loadCognitiveState() async {
        await MainActor.run { isLoadingCognitive = true }
        
        do {
            let state = try await apiService.fetchCognitiveState()
            await MainActor.run {
                self.cognitiveState = state
                self.isLoadingCognitive = false
            }
        } catch {
            await MainActor.run {
                self.isLoadingCognitive = false
            }
        }
    }
    
    func triggerAnalysis() {
        isAnalyzing = true
        
        Task {
            do {
                let analysis = try await apiService.triggerCognitiveAnalysis()
                await MainActor.run {
                    self.latestAnalysis = analysis
                    self.isAnalyzing = false
                    
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isAnalyzing = false
                    
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    func toggleAdmin(_ user: GhostUser) {
        Task {
            do {
                let updated = try await apiService.updateUserRole(userId: user.id, isAdmin: !user.isAdmin)
                await MainActor.run {
                    if let index = self.users.firstIndex(where: { $0.id == user.id }) {
                        self.users[index] = updated
                    }
                    
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.error)
                }
            }
        }
    }
}

#Preview {
    GhostProtocolView()
        .environmentObject(SovereignRuntime.shared)
}
