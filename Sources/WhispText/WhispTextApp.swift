import SwiftUI
import AppKit

@main
struct WhispTextApp: App {
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var whisperWrapper = WhisperWrapper()
    @StateObject private var hotkeyManager = HotkeyManager()
    
    @StateObject private var appSettings = AppSettings()
    
    // Check for accessibility
    @State private var accessibilityGranted = AXIsProcessTrusted()
    @State private var liveTranscriptionTask: Task<Void, Never>?
    
    var body: some Scene {
        MenuBarExtra(
            "WhispText",
            systemImage: audioRecorder.isRecording ? "mic.fill" : "mic.slash"
        ) {
            ContentView(
                audioRecorder: audioRecorder,
                whisperWrapper: whisperWrapper,
                hotkeyManager: hotkeyManager,
                appSettings: appSettings,
                accessibilityGranted: $accessibilityGranted
            )
            .onAppear {
                setupApp()
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    private func setupApp() {
        setupLogging()
        // Accessibility Check Loop
        if !accessibilityGranted {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let trusted = AXIsProcessTrusted()
                if trusted {
                    self.accessibilityGranted = true
                    timer.invalidate()
                    self.hotkeyManager.startMonitoring()
                }
            }
            
            // Prompt for accessibility if not granted
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
            AXIsProcessTrustedWithOptions(options)
        } else {
            self.hotkeyManager.startMonitoring()
        }
        
        // Setup Hotkey Logic
        hotkeyManager.onStart = {
            if !audioRecorder.isRecording {
                do {
                    try audioRecorder.startRecording()
                    if appSettings.enableLiveHUD {
                        HUDManager.shared.showHUD(text: "Listening...")
                        liveTranscriptionTask = Task {
                            while !Task.isCancelled {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                let frames = audioRecorder.getCurrentBuffer()
                                if let text = await whisperWrapper.transcribeLive(audioFrames: frames, language: appSettings.language) {
                                    DispatchQueue.main.async {
                                        HUDManager.shared.updateHUD(text: text)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("Could not start recording: \(error)")
                }
            }
        }
        
        hotkeyManager.onStop = {
            liveTranscriptionTask?.cancel()
            liveTranscriptionTask = nil
            if appSettings.enableLiveHUD {
                HUDManager.shared.hideHUD()
            }
            if audioRecorder.isRecording {
                let frames = audioRecorder.stopRecording()
                Task {
                    if let text = await whisperWrapper.transcribe(audioFrames: frames, language: appSettings.language), !text.isEmpty {
                        // Append a trailing space for nicer repeated transcriptions
                        TextInjector.paste(text: text + " ")
                    }
                }
            }
        }
        
        // Initialize WhisperKit Model dynamically based on user settings
        Task {
            await whisperWrapper.initialize(modelName: appSettings.modelSize)
        }
    }
}
