// TranspilerView.swift
// A6 - Q++RS Quantum Transpiler
// Convert Q++RS code to Swift/iOS

import SwiftUI

struct TranspilerView: View {
    @StateObject private var viewModel = TranspilerViewModel()
    @State private var qpprsCode: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        inputSection
                        transpileButton
                        
                        if viewModel.isTranspiling {
                            transpilingIndicator
                        }
                        
                        if let result = viewModel.transpileResult {
                            outputSection(result)
                        }
                        
                        if let error = viewModel.error {
                            errorSection(error)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Q++RS Transpiler")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1DE0C2").opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "atom")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "1DE0C2"))
            }
            
            Text("Quantum Transpiler")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Convert Q++RS to Swift/iOS")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 10)
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Q++RS Code")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: loadSampleCode) {
                    Text("Sample")
                        .font(.caption)
                        .foregroundColor(Color(hex: "1DE0C2"))
                }
            }
            
            TextEditor(text: $qpprsCode)
                .font(.system(.caption, design: .monospaced))
                .frame(minHeight: 150)
                .padding(12)
                .background(Color(hex: "0d0d14"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "1DE0C2").opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(Color(hex: "1DE0C2"))
        }
    }
    
    private var transpileButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            viewModel.transpile(code: qpprsCode)
        }) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Transpile to Swift")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(hex: "1DE0C2"), Color(hex: "8b5cf6")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .disabled(qpprsCode.isEmpty || viewModel.isTranspiling)
        .opacity(qpprsCode.isEmpty ? 0.5 : 1.0)
    }
    
    private var transpilingIndicator: some View {
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
                
                Image(systemName: "atom")
                    .foregroundColor(Color(hex: "1DE0C2"))
            }
            
            Text("Transpiling quantum code...")
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private func outputSection(_ result: TranspileResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            outputCard(title: "Swift Code", code: result.swift, icon: "swift")
            outputCard(title: "Quantum Runtime", code: result.quantumRuntime, icon: "cpu")
        }
    }
    
    private func outputCard(title: String, code: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "1DE0C2"))
                
                Text(title)
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Color(hex: "1DE0C2"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 150)
            .padding()
            .background(Color(hex: "0d0d14"))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
        )
    }
    
    private func errorSection(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(error)
                .foregroundColor(.red)
                .font(.subheadline)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func loadSampleCode() {
        qpprsCode = """
// Q++RS Quantum Hello World
qubit q[2];
hadamard q[0];
cnot q[0], q[1];
measure q[0] -> c[0];
emit "Bell state created";
"""
    }
    
    private func shareCode(_ code: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let activityVC = UIActivityViewController(activityItems: [code], applicationActivities: nil)
        window.rootViewController?.present(activityVC, animated: true)
    }
}

class TranspilerViewModel: ObservableObject {
    @Published var isTranspiling = false
    @Published var transpileResult: TranspileResult?
    @Published var error: String?
    @Published var rotationAngle: Double = 0
    
    private let apiService = APIService.shared
    
    func transpile(code: String) {
        isTranspiling = true
        transpileResult = nil
        error = nil
        rotationAngle = 0
        
        Task {
            do {
                let result = try await apiService.transpileQpprs(code: code)
                await MainActor.run {
                    self.transpileResult = result
                    self.isTranspiling = false
                    
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isTranspiling = false
                    
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.error)
                }
            }
        }
    }
}

#Preview {
    TranspilerView()
}
