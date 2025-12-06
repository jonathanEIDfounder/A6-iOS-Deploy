// CortexView.swift
// A6 - Cortex AI Reasoning Engine
// Q++RS Ultimate Agentic Reasoning Module

import SwiftUI

struct CortexView: View {
    @StateObject private var viewModel = CortexViewModel()
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        cortexHeader
                        metricsGrid
                        frameworkBreakdown
                        reasoningSection
                        agentStatus
                    }
                    .padding()
                }
            }
            .navigationTitle("Cortex")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadMetrics()
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
            .refreshable {
                await viewModel.refreshMetrics()
            }
        }
    }
    
    private var cortexHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1DE0C2").opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                
                Image(systemName: "brain")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: "1DE0C2"))
            }
            
            Text("Q* Reasoning Engine")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Agentic AI Orchestration")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top)
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(title: "Generations", value: "\(viewModel.totalGenerations)", icon: "wand.and.stars", isLoading: viewModel.isLoading)
            MetricCard(title: "Success Rate", value: "\(viewModel.successRate)%", icon: "checkmark.circle", isLoading: viewModel.isLoading)
            MetricCard(title: "Recent (24h)", value: "\(viewModel.recentGenerations)", icon: "clock", isLoading: viewModel.isLoading)
            MetricCard(title: "Frameworks", value: "7", icon: "square.stack.3d.up", isLoading: false)
        }
    }
    
    private var frameworkBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Framework Usage")
                .font(.headline)
                .foregroundColor(.white)
            
            if viewModel.frameworkBreakdown.isEmpty && !viewModel.isLoading {
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "1a1a2e"))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.frameworkBreakdown.keys.sorted()), id: \.self) { framework in
                        if let count = viewModel.frameworkBreakdown[framework] {
                            FrameworkBar(
                                name: framework,
                                count: count,
                                total: viewModel.totalGenerations
                            )
                        }
                    }
                }
                .padding()
                .background(Color(hex: "1a1a2e"))
                .cornerRadius(12)
            }
        }
    }
    
    private var reasoningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Q* Reasoning Status")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ReasoningStep(step: "DAG Solver", status: .active)
                ReasoningStep(step: "Framework Selection", status: .complete)
                ReasoningStep(step: "Code Synthesis", status: .complete)
                ReasoningStep(step: "Security Verification", status: .active)
            }
            .padding()
            .background(Color(hex: "1a1a2e"))
            .cornerRadius(12)
        }
    }
    
    private var agentStatus: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Agent Crew")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                AgentRow(name: "Architect", model: "GPT-5-Orion", status: .online)
                AgentRow(name: "Coder", model: "Claude-4", status: .online)
                AgentRow(name: "Reviewer", model: "Gemini-2", status: .standby)
                AgentRow(name: "Deployer", model: "Local", status: .standby)
            }
            .padding()
            .background(Color(hex: "1a1a2e"))
            .cornerRadius(12)
        }
    }
}

struct FrameworkBar: View {
    let name: String
    let count: Int
    let total: Int
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var color: Color {
        switch name.lowercased() {
        case "react": return Color(hex: "61DAFB")
        case "vue": return Color(hex: "42b883")
        case "flutter": return Color(hex: "02569B")
        case "swiftui": return Color(hex: "F05138")
        case "q++rs", "q++rs ultimate": return Color(hex: "8b5cf6")
        case "html/css": return Color(hex: "E44D26")
        case "jetpack compose": return Color(hex: "3DDC84")
        default: return Color(hex: "1DE0C2")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: "0d0d14"))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "1DE0C2"))
            
            if isLoading {
                ProgressView()
                    .tint(Color(hex: "1DE0C2"))
            } else {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
    }
}

struct ReasoningStep: View {
    let step: String
    let status: StepStatus
    
    enum StepStatus {
        case pending, active, complete
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(step)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(statusColor)
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .gray
        case .active: return Color(hex: "1DE0C2")
        case .complete: return .green
        }
    }
    
    private var statusText: String {
        switch status {
        case .pending: return "Pending"
        case .active: return "Active"
        case .complete: return "Complete"
        }
    }
}

struct AgentRow: View {
    let name: String
    let model: String
    let status: AgentStatus
    
    enum AgentStatus {
        case online, standby, offline
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                
                Text(model)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(statusText)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(4)
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .online: return .green
        case .standby: return .orange
        case .offline: return .red
        }
    }
    
    private var statusText: String {
        switch status {
        case .online: return "Online"
        case .standby: return "Standby"
        case .offline: return "Offline"
        }
    }
}

class CortexViewModel: ObservableObject {
    @Published var totalGenerations = 0
    @Published var recentGenerations = 0
    @Published var successRate = 99
    @Published var frameworkBreakdown: [String: Int] = [:]
    @Published var isLoading = false
    
    private let apiService = APIService.shared
    
    func loadMetrics() {
        isLoading = true
        
        Task {
            do {
                let stats = try await apiService.fetchStats()
                await MainActor.run {
                    withAnimation(.spring(response: 0.4)) {
                        self.totalGenerations = stats.totalGenerations
                        self.recentGenerations = stats.recentGenerations
                        self.frameworkBreakdown = stats.frameworkBreakdown
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshMetrics() async {
        do {
            let stats = try await apiService.fetchStats()
            await MainActor.run {
                withAnimation(.spring(response: 0.4)) {
                    self.totalGenerations = stats.totalGenerations
                    self.recentGenerations = stats.recentGenerations
                    self.frameworkBreakdown = stats.frameworkBreakdown
                }
            }
        } catch {
            // Silent fail on refresh
        }
    }
}

#Preview {
    CortexView()
}
