// GenerateView.swift
// A6 - Code Generation Interface
// iPhone XR Native

import SwiftUI

struct GenerateView: View {
    @StateObject private var viewModel = GenerateViewModel()
    @State private var prompt: String = ""
    @State private var selectedFramework: Framework = .react
    @State private var showShareSheet = false
    
    enum Framework: String, CaseIterable {
        case react = "React"
        case vue = "Vue"
        case htmlCss = "HTML/CSS"
        case flutter = "Flutter"
        case swiftUI = "SwiftUI"
        case jetpack = "Jetpack Compose"
        case qpprs = "Q++RS Ultimate"
        
        var icon: String {
            switch self {
            case .react: return "atom"
            case .vue: return "leaf"
            case .htmlCss: return "chevron.left.forwardslash.chevron.right"
            case .flutter: return "bird"
            case .swiftUI: return "swift"
            case .jetpack: return "android.logo"
            case .qpprs: return "waveform.path.ecg"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        frameworkPicker
                        promptInput
                        generateButton
                        
                        if viewModel.isGenerating {
                            generatingIndicator
                        }
                        
                        if let code = viewModel.generatedCode {
                            codePreview(code)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Generate")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1DE0C2").opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "1DE0C2"))
            }
            
            Text("A6 Code Generator")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Describe what you want to build")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 10)
    }
    
    private var frameworkPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Framework")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Framework.allCases, id: \.self) { framework in
                        FrameworkChip(
                            name: framework.rawValue,
                            icon: framework.icon,
                            isSelected: selectedFramework == framework
                        ) {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            withAnimation(.spring(response: 0.3)) {
                                selectedFramework = framework
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var promptInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Describe your component")
                .font(.headline)
                .foregroundColor(.white)
            
            TextEditor(text: $prompt)
                .frame(minHeight: 120)
                .padding(12)
                .background(Color(hex: "1a1a2e"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "1DE0C2").opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(.white)
        }
    }
    
    private var generateButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            viewModel.generateCode(prompt: prompt, framework: selectedFramework.rawValue)
        }) {
            HStack {
                Image(systemName: "sparkles")
                Text("Generate Code")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(hex: "1DE0C2"), Color(hex: "0ea5e9")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .disabled(prompt.isEmpty || viewModel.isGenerating)
        .opacity(prompt.isEmpty ? 0.5 : 1.0)
        .scaleEffect(viewModel.isGenerating ? 0.98 : 1.0)
        .animation(.spring(response: 0.3), value: viewModel.isGenerating)
    }
    
    private var generatingIndicator: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(hex: "1DE0C2").opacity(0.3), lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color(hex: "1DE0C2"), lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(viewModel.rotationAngle))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.rotationAngle)
                    .onAppear { viewModel.rotationAngle = 360 }
            }
            
            Text("Generating \(selectedFramework.rawValue) code...")
                .foregroundColor(.gray)
        }
        .padding()
        .transition(.opacity.combined(with: .scale))
    }
    
    private func codePreview(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Generated Code")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = code
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(Color(hex: "1DE0C2"))
                }
                
                Button(action: {
                    shareCode(code)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(Color(hex: "1DE0C2"))
                }
            }
            
            ScrollView {
                Text(code)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Color(hex: "1DE0C2"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 300)
            .padding()
            .background(Color(hex: "0d0d14"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
            )
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    private func shareCode(_ code: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let activityVC = UIActivityViewController(activityItems: [code], applicationActivities: nil)
        window.rootViewController?.present(activityVC, animated: true)
    }
}

struct FrameworkChip: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color(hex: "1DE0C2") : Color(hex: "1a1a2e"))
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "1DE0C2").opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
    }
}

class GenerateViewModel: ObservableObject {
    @Published var isGenerating = false
    @Published var generatedCode: String?
    @Published var error: String?
    @Published var rotationAngle: Double = 0
    
    private let apiService = APIService.shared
    
    func generateCode(prompt: String, framework: String) {
        isGenerating = true
        generatedCode = nil
        error = nil
        rotationAngle = 0
        
        Task {
            do {
                let code = try await apiService.generateCode(prompt: prompt, framework: framework)
                await MainActor.run {
                    withAnimation(.spring(response: 0.4)) {
                        self.generatedCode = code
                    }
                    self.isGenerating = false
                    
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isGenerating = false
                    
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.error)
                }
            }
        }
    }
}

#Preview {
    GenerateView()
}
