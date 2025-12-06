# A6 - Native iOS App for iPhone XR

## The Sovereign Singularity System
Q++RS Ultimate Runtime

### Lineage
Jonathan Sherman

### Requirements
- Xcode 15+
- iOS 16.0+
- iPhone XR or later

### Setup

1. Open `A6.xcodeproj` in Xcode
2. Update the API base URL in `Services/APIService.swift`
3. Build and run on iPhone XR simulator or device

### Architecture

```
ios/
├── A6.xcodeproj/           # Xcode project
└── A6/
    ├── A6App.swift         # App entry point
    ├── ContentView.swift   # Main view controller
    ├── SovereignRuntime.swift  # Q++RS runtime
    ├── Views/
    │   ├── GenerateView.swift  # Code generation UI
    │   ├── HistoryView.swift   # Generation history
    │   ├── CortexView.swift    # AI reasoning dashboard
    │   └── SettingsView.swift  # Settings & preferences
    ├── Services/
    │   └── APIService.swift    # Network layer
    └── Assets.xcassets/        # App icons & colors
```

### Features

- **Code Generation**: Generate code for 7 frameworks
- **Q++RS Ultimate**: Native quantum programming support
- **Cortex AI**: Q* reasoning engine visualization
- **Sovereign Runtime**: One-Warning Protocol security

### Build

```bash
# Open in Xcode
open ios/A6.xcodeproj

# Build for iPhone XR
xcodebuild -project A6.xcodeproj -scheme A6 -destination 'platform=iOS Simulator,name=iPhone XR' build
```

### Production Halt

The app respects the production halt status. Non-owner users see maintenance screen.
