// HistoryView.swift
// A6 - Generation History
// iPhone XR Native

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.generations.isEmpty {
                    ProgressView()
                        .tint(Color(hex: "1DE0C2"))
                } else if viewModel.generations.isEmpty {
                    emptyState
                } else {
                    generationList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadHistory()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1DE0C2").opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 36))
                    .foregroundColor(.gray)
            }
            
            Text("No generations yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Your code generation history will appear here")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var generationList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.generations) { generation in
                    GenerationCard(generation: generation)
                        .transition(.opacity.combined(with: .slide))
                }
            }
            .padding()
        }
        .refreshable {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            await viewModel.refreshHistory()
        }
    }
}

struct GenerationCard: View {
    let generation: Generation
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(generation.framework)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(frameworkColor.opacity(0.2))
                            .foregroundColor(frameworkColor)
                            .cornerRadius(4)
                        
                        Text(generation.createdAt, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Text(generation.prompt)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(isExpanded ? nil : 2)
                }
                
                Spacer()
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }
            }
            
            if isExpanded {
                ScrollView {
                    Text(generation.code)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(Color(hex: "1DE0C2"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
                .padding(8)
                .background(Color(hex: "0d0d14"))
                .cornerRadius(8)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
                HStack {
                    Button(action: {
                        UIPasteboard.general.string = generation.code
                        let notificationFeedback = UINotificationFeedbackGenerator()
                        notificationFeedback.notificationOccurred(.success)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(hex: "1DE0C2"))
                    
                    Button(action: {
                        shareCode(generation.code)
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(hex: "0ea5e9"))
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.1), lineWidth: 1)
        )
    }
    
    private var frameworkColor: Color {
        switch generation.framework.lowercased() {
        case "react": return Color(hex: "61DAFB")
        case "vue": return Color(hex: "42b883")
        case "flutter": return Color(hex: "02569B")
        case "swiftui": return Color(hex: "F05138")
        case "q++rs": return Color(hex: "8b5cf6")
        default: return Color(hex: "1DE0C2")
        }
    }
    
    private func shareCode(_ code: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let activityVC = UIActivityViewController(activityItems: [code], applicationActivities: nil)
        window.rootViewController?.present(activityVC, animated: true)
    }
}

struct Generation: Identifiable {
    let id: Int
    let framework: String
    let prompt: String
    let code: String
    let createdAt: Date
}

class HistoryViewModel: ObservableObject {
    @Published var generations: [Generation] = []
    @Published var isLoading = false
    
    private let apiService = APIService.shared
    
    func loadHistory() {
        isLoading = true
        
        Task {
            do {
                let history = try await apiService.fetchHistory()
                await MainActor.run {
                    withAnimation(.spring(response: 0.4)) {
                        self.generations = history
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
    
    func refreshHistory() async {
        do {
            let history = try await apiService.fetchHistory()
            await MainActor.run {
                withAnimation(.spring(response: 0.4)) {
                    self.generations = history
                }
            }
        } catch {
            // Silent fail on refresh
        }
    }
}

#Preview {
    HistoryView()
}
