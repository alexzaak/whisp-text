import SwiftUI

struct ContentView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @ObservedObject var whisperWrapper: WhisperWrapper
    @ObservedObject var hotkeyManager: HotkeyManager
    @ObservedObject var appSettings: AppSettings
    @Binding var accessibilityGranted: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("WhispText")
                .font(.headline)
            
            if !accessibilityGranted {
                VStack {
                    Text("⚠️ Accessibility Permissions Required")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Text("Please grant accessibility permissions in System Settings to use the global hotkey and paste functionality.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Open Preferences") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .font(.caption)
                }
                .padding(.horizontal)
            }
            
            if !whisperWrapper.isModelLoaded {
                ProgressView("Loading WhisperKit model...")
                    .font(.caption)
            } else {
                HStack {
                    Circle()
                        .fill(audioRecorder.isRecording ? Color.red : Color.gray)
                        .frame(width: 10, height: 10)
                    Text(audioRecorder.isRecording ? "Recording... (Press Fn+Shift to stop)" : "Idle (Press Fn+Shift to start)")
                        .font(.caption)
                }
                
                Button(action: {
                    if audioRecorder.isRecording {
                        hotkeyManager.onStop?()
                    } else {
                        hotkeyManager.onStart?()
                    }
                }) {
                    Text(audioRecorder.isRecording ? "Stop & Transcribe" : "Start Recording")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Toggle("Enable Live Transcription HUD", isOn: $appSettings.enableLiveHUD)
                    .font(.caption)
                
                HStack {
                    Text("Model Tier:")
                        .font(.caption)
                    Spacer()
                    Picker("", selection: $appSettings.modelSize) {
                        Text("Tiny").tag("tiny")
                        Text("Base").tag("base")
                        Text("Small").tag("small")
                    }
                    .labelsHidden()
                    .frame(width: 100)
                    .onChange(of: appSettings.modelSize) { newValue in
                        Task {
                            await whisperWrapper.initialize(modelName: newValue)
                        }
                    }
                }
                
                HStack {
                    Text("Language:")
                        .font(.caption)
                    Spacer()
                    Picker("", selection: $appSettings.language) {
                        Text("German").tag("de")
                        Text("English").tag("en")
                        Text("Auto").tag("auto")
                    }
                    .labelsHidden()
                    .frame(width: 100)
                }
            }
            
            Divider()
            
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                Spacer()
            }
        }
        .padding()
        .frame(width: 300)
    }
}
