import Foundation
import WhisperKit

class WhisperWrapper: ObservableObject {
    private var pipe: WhisperKit?
    @Published var isModelLoaded = false
    
    func initialize(modelName: String = "tiny") async {
        do {
            DispatchQueue.main.async {
                self.isModelLoaded = false
            }
            
            print("Initializing WhisperKit with \(modelName) model...")
            self.pipe = try await WhisperKit(model: modelName)
            
            // CoreML models need to compile their execution graphs on the Neural Engine
            // the very first time they are used, which can take 1-2 minutes.
            // We force a silent "dummy transcription" immediately at boot to get it out of the way!
            print("Warming up Neural Engine...")
            let dummyAudio = [Float](repeating: 0.0, count: 16000)
            _ = try? await self.pipe?.transcribe(audioArray: dummyAudio)
            print("Neural Engine ready!")
            
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
