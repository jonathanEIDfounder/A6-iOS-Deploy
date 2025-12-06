// HolographicTextileView.swift
// A6 - 3D Holographic Textile UI
// Alesis-inspired music production interface
// Canvas with fabric options and neon effects

import SwiftUI

struct HolographicTextileView: View {
    @State private var selectedFabric: FabricType = .canvas
    @State private var neonColor: NeonColor = .cyan
    @State private var wavePhase: Double = 0
    
    // Mixer channel levels (functional knobs)
    @State private var hologramIntensity: Double = 0.7
    @State private var glowRadius: Double = 0.5
    @State private var waveSpeed: Double = 0.5
    @State private var scanlineOpacity: Double = 0.3
    @State private var patternDensity: Double = 0.6
    @State private var colorSaturation: Double = 0.8
    
    // Transport state
    @State private var isPlaying: Bool = true
    @State private var isRecording: Bool = false
    
    // Pad grid state (4x4)
    @State private var activePads: Set<Int> = []
    
    // VU meter levels
    @State private var vuLevelL: Double = 0.6
    @State private var vuLevelR: Double = 0.55
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0a0a0f").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        holographicCanvas
                        transportControls
                        mixerSection
                        padGrid
                        fabricSelector
                        neonColorPicker
                    }
                    .padding()
                }
            }
            .navigationTitle("Holographic Studio")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Holographic Canvas Preview
    
    private var holographicCanvas: some View {
        ZStack {
            TextileCanvas(
                fabric: selectedFabric,
                neonColor: neonColor.color.opacity(colorSaturation),
                intensity: hologramIntensity,
                phase: wavePhase,
                patternDensity: patternDensity
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HolographicOverlay(
                color: neonColor.color,
                intensity: hologramIntensity,
                phase: wavePhase,
                scanlineOpacity: scanlineOpacity,
                glowRadius: glowRadius
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)
            
            // Status overlay
            VStack {
                HStack {
                    if isRecording {
                        HStack(spacing: 4) {
                            Circle().fill(Color.red).frame(width: 8, height: 8)
                            Text("REC")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                    }
                    Spacer()
                    Text(selectedFabric.displayName.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(neonColor.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                }
                Spacer()
            }
            .padding(10)
            .frame(height: 200)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(neonColor.color.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: neonColor.color.opacity(glowRadius * 0.4), radius: glowRadius * 30)
    }
    
    // MARK: - Transport Controls (Alesis style)
    
    private var transportControls: some View {
        HStack(spacing: 0) {
            // VU Meters
            HStack(spacing: 4) {
                VUMeter(level: vuLevelL, color: neonColor.color, label: "L")
                VUMeter(level: vuLevelR, color: neonColor.color, label: "R")
            }
            .frame(width: 60)
            
            Spacer()
            
            // Transport buttons
            HStack(spacing: 16) {
                TransportButton(icon: "backward.end.fill", isActive: false) {
                    // Rewind - reset all to defaults
                    resetToDefaults()
                }
                
                TransportButton(icon: isPlaying ? "pause.fill" : "play.fill", isActive: isPlaying) {
                    isPlaying.toggle()
                    if isPlaying { startAnimations() }
                }
                
                TransportButton(icon: "stop.fill", isActive: false) {
                    isPlaying = false
                    isRecording = false
                }
                
                TransportButton(icon: "circle.fill", isActive: isRecording, activeColor: .red) {
                    isRecording.toggle()
                }
                
                TransportButton(icon: "forward.end.fill", isActive: false) {
                    // Fast forward - randomize settings
                    randomizeSettings()
                }
            }
            
            Spacer()
            
            // BPM Display
            VStack(spacing: 2) {
                Text("SPD")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                Text("\(Int(waveSpeed * 200))")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(neonColor.color)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(Color(hex: "0d0d14"))
            .cornerRadius(6)
        }
        .padding(12)
        .background(Color(hex: "151520"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Mixer Section with Functional Knobs
    
    private var mixerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MIXER")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            
            HStack(spacing: 0) {
                MixerChannel(
                    label: "HOLO",
                    value: $hologramIntensity,
                    color: neonColor.color,
                    description: "Hologram intensity"
                )
                
                MixerChannel(
                    label: "GLOW",
                    value: $glowRadius,
                    color: neonColor.color,
                    description: "Neon glow radius"
                )
                
                MixerChannel(
                    label: "WAVE",
                    value: $waveSpeed,
                    color: neonColor.color,
                    description: "Animation speed"
                )
                
                MixerChannel(
                    label: "SCAN",
                    value: $scanlineOpacity,
                    color: neonColor.color,
                    description: "Scanline opacity"
                )
                
                MixerChannel(
                    label: "DENS",
                    value: $patternDensity,
                    color: neonColor.color,
                    description: "Pattern density"
                )
                
                MixerChannel(
                    label: "SAT",
                    value: $colorSaturation,
                    color: neonColor.color,
                    description: "Color saturation"
                )
            }
        }
        .padding(12)
        .background(Color(hex: "0d0d14"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - LED Pad Grid (4x4)
    
    private var padGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PAD BANK")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(activePads.count) ACTIVE")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(neonColor.color)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(0..<16, id: \.self) { index in
                    PadButton(
                        index: index,
                        isActive: activePads.contains(index),
                        color: padColor(for: index),
                        action: {
                            padTapped(index)
                        }
                    )
                }
            }
        }
        .padding(12)
        .background(Color(hex: "0d0d14"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Fabric Selector
    
    private var fabricSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TEXTURE")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(FabricType.allCases, id: \.self) { fabric in
                        FabricChip(
                            fabric: fabric,
                            isSelected: selectedFabric == fabric,
                            neonColor: neonColor.color
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedFabric = fabric
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(hex: "0d0d14"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Neon Color Picker
    
    private var neonColorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NEON")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                ForEach(NeonColor.allCases, id: \.self) { color in
                    NeonColorButton(
                        neonColor: color,
                        isSelected: neonColor == color
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            neonColor = color
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(12)
        .background(Color(hex: "0d0d14"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Functions
    
    private func startAnimations() {
        animateWave()
        animateVU()
    }
    
    private func animateWave() {
        guard isPlaying else { return }
        let duration = 4.0 / (waveSpeed + 0.1)
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            wavePhase = .pi * 2
        }
    }
    
    private func animateVU() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if isPlaying {
                vuLevelL = Double.random(in: 0.3...0.9)
                vuLevelR = Double.random(in: 0.3...0.9)
            } else {
                vuLevelL = max(0, vuLevelL - 0.05)
                vuLevelR = max(0, vuLevelR - 0.05)
            }
        }
    }
    
    private func resetToDefaults() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hologramIntensity = 0.7
            glowRadius = 0.5
            waveSpeed = 0.5
            scanlineOpacity = 0.3
            patternDensity = 0.6
            colorSaturation = 0.8
            activePads.removeAll()
        }
    }
    
    private func randomizeSettings() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hologramIntensity = Double.random(in: 0.3...1.0)
            glowRadius = Double.random(in: 0.2...1.0)
            waveSpeed = Double.random(in: 0.2...1.0)
            scanlineOpacity = Double.random(in: 0.1...0.6)
            patternDensity = Double.random(in: 0.3...1.0)
            colorSaturation = Double.random(in: 0.5...1.0)
        }
    }
    
    private func padTapped(_ index: Int) {
        if activePads.contains(index) {
            activePads.remove(index)
        } else {
            activePads.insert(index)
            applyPadEffect(index)
        }
    }
    
    private func applyPadEffect(_ index: Int) {
        // Pads trigger different effects
        switch index {
        case 0: selectedFabric = .canvas
        case 1: selectedFabric = .silk
        case 2: selectedFabric = .denim
        case 3: selectedFabric = .leather
        case 4: selectedFabric = .velvet
        case 5: selectedFabric = .mesh
        case 6: selectedFabric = .carbon
        case 7: selectedFabric = .holographic
        case 8: neonColor = .cyan
        case 9: neonColor = .magenta
        case 10: neonColor = .lime
        case 11: neonColor = .orange
        case 12: neonColor = .purple
        case 13: neonColor = .gold
        case 14: randomizeSettings()
        case 15: resetToDefaults()
        default: break
        }
    }
    
    private func padColor(for index: Int) -> Color {
        switch index {
        case 0...7: return FabricType.allCases[index].baseColor
        case 8...13:
            let colors: [NeonColor] = [.cyan, .magenta, .lime, .orange, .purple, .gold]
            return colors[index - 8].color
        case 14: return Color.orange
        case 15: return Color.red
        default: return .gray
        }
    }
}

// MARK: - VU Meter

struct VUMeter: View {
    let level: Double
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "1a1a1a"))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.yellow, Color.red],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: geometry.size.height * level)
                }
            }
            .frame(width: 12, height: 60)
            
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Transport Button

struct TransportButton: View {
    let icon: String
    let isActive: Bool
    var activeColor: Color = Color(hex: "1DE0C2")
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isActive ? activeColor : .gray)
                .frame(width: 40, height: 40)
                .background(Color(hex: isActive ? "1a1a2e" : "0d0d14"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? activeColor.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: isActive ? activeColor.opacity(0.3) : .clear, radius: 6)
        }
    }
}

// MARK: - Mixer Channel with Rotary Knob

struct MixerChannel: View {
    let label: String
    @Binding var value: Double
    let color: Color
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Value display
            Text("\(Int(value * 100))")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            
            // Rotary knob
            RotaryKnob(value: $value, color: color)
            
            // Label
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Rotary Knob (Functional)

struct RotaryKnob: View {
    @Binding var value: Double
    let color: Color
    
    @State private var lastAngle: Double = 0
    
    private let minAngle: Double = -135
    private let maxAngle: Double = 135
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color(hex: "2a2a3a"), lineWidth: 3)
                
                // Value arc
                Circle()
                    .trim(from: 0, to: value * 0.75)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(135))
                
                // Knob body
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "3a3a4a"), Color(hex: "1a1a2a")],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: size * 0.6
                        )
                    )
                    .padding(6)
                
                // Indicator line
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: size * 0.25)
                    .offset(y: -size * 0.18)
                    .rotationEffect(.degrees(minAngle + (maxAngle - minAngle) * value))
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let center = CGPoint(x: size / 2, y: size / 2)
                        let location = gesture.location
                        
                        let angle = atan2(location.y - center.y, location.x - center.x)
                        let degrees = angle * 180 / .pi + 90
                        
                        let normalizedAngle = degrees < -135 ? degrees + 360 : degrees
                        let clampedAngle = max(minAngle, min(maxAngle, normalizedAngle))
                        
                        let newValue = (clampedAngle - minAngle) / (maxAngle - minAngle)
                        value = max(0, min(1, newValue))
                    }
            )
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Pad Button

struct PadButton: View {
    let index: Int
    let isActive: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? color.opacity(0.8) : Color(hex: "1a1a2a"))
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(isActive ? 0.8 : 0.3), lineWidth: 1)
                
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(isActive ? .black : color.opacity(0.6))
            }
            .frame(height: 50)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: isActive ? color.opacity(0.5) : .clear, radius: 8)
        }
        .animation(.easeOut(duration: 0.1), value: isPressed)
    }
}

// MARK: - Fabric Types

enum FabricType: String, CaseIterable {
    case canvas, silk, denim, leather, velvet, mesh, carbon, holographic
    
    var displayName: String { rawValue.capitalized }
    
    var pattern: FabricPattern {
        switch self {
        case .canvas: return .woven
        case .silk: return .smooth
        case .denim: return .diagonal
        case .leather: return .grain
        case .velvet: return .plush
        case .mesh: return .grid
        case .carbon: return .weave
        case .holographic: return .prism
        }
    }
    
    var baseColor: Color {
        switch self {
        case .canvas: return Color(hex: "2a2a3a")
        case .silk: return Color(hex: "1a1a2e")
        case .denim: return Color(hex: "1a2a4a")
        case .leather: return Color(hex: "2a1a1a")
        case .velvet: return Color(hex: "2a1a3a")
        case .mesh: return Color(hex: "1a1a1a")
        case .carbon: return Color(hex: "0a0a0a")
        case .holographic: return Color(hex: "0d0d14")
        }
    }
}

enum FabricPattern {
    case woven, smooth, diagonal, grain, plush, grid, weave, prism
}

// MARK: - Neon Colors

enum NeonColor: String, CaseIterable {
    case cyan, magenta, lime, orange, purple, gold
    
    var color: Color {
        switch self {
        case .cyan: return Color(hex: "1DE0C2")
        case .magenta: return Color(hex: "FF00FF")
        case .lime: return Color(hex: "39FF14")
        case .orange: return Color(hex: "FF6B35")
        case .purple: return Color(hex: "A855F7")
        case .gold: return Color(hex: "FFD700")
        }
    }
}

// MARK: - Textile Canvas

struct TextileCanvas: View {
    let fabric: FabricType
    let neonColor: Color
    let intensity: Double
    let phase: Double
    let patternDensity: Double
    
    var body: some View {
        Canvas { context, size in
            drawFabricBase(context: context, size: size)
            drawFabricPattern(context: context, size: size)
            drawNeonHighlights(context: context, size: size)
        }
        .background(fabric.baseColor)
    }
    
    private func drawFabricBase(context: GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        context.fill(Path(rect), with: .color(fabric.baseColor))
    }
    
    private func drawFabricPattern(context: GraphicsContext, size: CGSize) {
        let density = max(4, 16 - patternDensity * 12)
        
        switch fabric.pattern {
        case .woven:
            let spacing = density
            for y in stride(from: 0, to: size.height, by: spacing) {
                for x in stride(from: 0, to: size.width, by: spacing) {
                    let isAlt = (Int(x / spacing) + Int(y / spacing)) % 2 == 0
                    let opacity = isAlt ? 0.15 * patternDensity : 0.05 * patternDensity
                    let rect = CGRect(x: x, y: y, width: spacing - 1, height: spacing - 1)
                    context.fill(Path(rect), with: .color(.white.opacity(opacity)))
                }
            }
        case .smooth:
            let gradient = Gradient(colors: [
                Color.white.opacity(0.05 * patternDensity),
                Color.white.opacity(0.1 * patternDensity),
                Color.white.opacity(0.05 * patternDensity)
            ])
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .linearGradient(gradient, startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)))
        case .diagonal:
            let spacing = density
            for i in stride(from: -size.height, to: size.width + size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: i, y: 0))
                path.addLine(to: CGPoint(x: i + size.height, y: size.height))
                context.stroke(path, with: .color(.white.opacity(0.08 * patternDensity)), lineWidth: 1)
            }
        case .grain:
            let count = Int(200 * patternDensity)
            for _ in 0..<count {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let w = CGFloat.random(in: 2...6)
                let h = CGFloat.random(in: 1...3)
                let rect = CGRect(x: x, y: y, width: w, height: h)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(CGFloat.random(in: 0.02...0.08))))
            }
        case .plush:
            let count = Int(300 * patternDensity)
            for _ in 0..<count {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let r = CGFloat.random(in: 1...4)
                let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(CGFloat.random(in: 0.03...0.1))))
            }
        case .grid:
            let spacing = density
            for x in stride(from: 0, to: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(neonColor.opacity(0.2 * patternDensity)), lineWidth: 1)
            }
            for y in stride(from: 0, to: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(neonColor.opacity(0.2 * patternDensity)), lineWidth: 1)
            }
        case .weave:
            let spacing = density
            for y in stride(from: 0, to: size.height, by: spacing) {
                for x in stride(from: 0, to: size.width, by: spacing * 2) {
                    let offset = Int(y / spacing) % 2 == 0 ? 0 : spacing
                    let rect = CGRect(x: x + offset, y: y, width: spacing - 1, height: spacing - 1)
                    context.fill(Path(rect), with: .color(.white.opacity(0.1 * patternDensity)))
                }
            }
        case .prism:
            let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
            let bandWidth = size.width / CGFloat(colors.count)
            for (index, color) in colors.enumerated() {
                let x = CGFloat(index) * bandWidth
                let rect = CGRect(x: x, y: 0, width: bandWidth, height: size.height)
                context.fill(Path(rect), with: .color(color.opacity(0.15 * patternDensity)))
            }
        }
    }
    
    private func drawNeonHighlights(context: GraphicsContext, size: CGSize) {
        let waveHeight: CGFloat = 30 * intensity
        var path = Path()
        path.move(to: CGPoint(x: 0, y: size.height / 2))
        for x in stride(from: 0, to: size.width, by: 2) {
            let y = size.height / 2 + sin(x * 0.02 + phase) * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        context.stroke(path, with: .color(neonColor.opacity(0.6 * intensity)), lineWidth: 2)
        context.stroke(path, with: .color(neonColor.opacity(0.2 * intensity)), lineWidth: 8)
    }
}

// MARK: - Holographic Overlay

struct HolographicOverlay: View {
    let color: Color
    let intensity: Double
    let phase: Double
    let scanlineOpacity: Double
    let glowRadius: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        color.opacity(0.0),
                        color.opacity(0.1 * intensity),
                        color.opacity(0.0),
                        color.opacity(0.15 * intensity),
                        color.opacity(0.0)
                    ],
                    startPoint: UnitPoint(x: phase.truncatingRemainder(dividingBy: 1), y: 0),
                    endPoint: UnitPoint(x: (phase + 0.5).truncatingRemainder(dividingBy: 1), y: 1)
                )
                
                RadialGradient(
                    colors: [color.opacity(0.2 * intensity * glowRadius), color.opacity(0.0)],
                    center: UnitPoint(x: 0.5 + sin(phase) * 0.3, y: 0.5 + cos(phase) * 0.3),
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.6 * glowRadius
                )
                
                Canvas { context, canvasSize in
                    let lineSpacing: CGFloat = 4
                    for y in stride(from: 0, to: canvasSize.height, by: lineSpacing) {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                        context.stroke(path, with: .color(Color.black.opacity(scanlineOpacity * 0.3)), lineWidth: 1)
                    }
                }
            }
        }
    }
}

// MARK: - Fabric Chip

struct FabricChip: View {
    let fabric: FabricType
    let isSelected: Bool
    let neonColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(fabric.baseColor)
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? neonColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? neonColor.opacity(0.5) : .clear, radius: 6)
                
                Text(fabric.displayName)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(isSelected ? neonColor : .gray)
            }
        }
    }
}

// MARK: - Neon Color Button

struct NeonColorButton: View {
    let neonColor: NeonColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(neonColor.color)
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(Color.white, lineWidth: isSelected ? 2 : 0))
                .shadow(color: neonColor.color.opacity(isSelected ? 0.8 : 0.3), radius: isSelected ? 10 : 4)
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
    }
}

#Preview {
    HolographicTextileView()
}
