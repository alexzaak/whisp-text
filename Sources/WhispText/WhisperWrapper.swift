import Foundation
import WhisperKit

class WhisperWrapper: ObservableObject {
    private var pipe: WhisperKit?
    @Published var isModelLoaded = false
    
    func initialize() async {
        do {
            print("Initializing WhisperKit with tiny.en model...")
            // Force the 'tiny.en' model to avoid cached corrupted large models and improve speed.
            self.pipe = try await WhisperKit(model: "tiny.en")
            DispatchQueue.main.async {
                self.isModelLoaded = true
                print("WhisperKit model initialized successfully!")
            }
        } catch {
            print("Failed to initialize WhisperKit: \(error)")
        }
    }
    
    func transcribe(audioFrames: [Float]) async -> String? {
        guard let pipe = pipe else {
            print("WhisperKit not initialized.")
            return nil
        }
        guard audioFrames.count > 0 else {
            print("No audio frames recorded, skipping transcription.")
            return nil
        }
        
        do {
            print("Transcribing \(audioFrames.count) frames...")
            let results = try await pipe.transcribe(audioArray: audioFrames)
            
            if let firstResult = results.first {
                let cleaned = filterHallucinations(firstResult.text)
                print("Transcription Output: \(cleaned)")
                return cleaned
            }
            print("No transcription results returned.")
            return nil
        } catch {
            print("Transcription failed: \(error)")
            return nil
        }
    }
    
    func transcribeLive(audioFrames: [Float]) async -> String? {
        guard let pipe = pipe else { return nil }
        // 8000 frames = 0.5s of audio to trigger first word
        guard audioFrames.count > 8000 else { return nil }
        
        do {
            let results = try await pipe.transcribe(audioArray: audioFrames)
            if let firstResult = results.first {
                return filterHallucinations(firstResult.text)
            }
            return nil
        } catch {
            return nil
        }
    }
    
    private func filterHallucinations(_ text: String) -> String {
        var filtered = text
        let blocklist = [
            "[BLANK_AUDIO]", "[BLANK AUDIO]", "(BLANK_AUDIO)",
            "[Silence]", "(Silence)", "*Silence*",
            "[silence]", "(silence)", "*silence*",
            "[Pause]", "(Pause)",
            "[INAUDIBLE]", "(INAUDIBLE)"
        ]
        
        for token in blocklist {
            filtered = filtered.replacingOccurrences(of: token, with: "")
        }
        
        return filtered.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
