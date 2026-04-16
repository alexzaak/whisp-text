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
            
            // Results is usually an array of transcription results or a single result,
            // WhisperKit's transcribe method usually returns a single TranscriptionResult or array.
            // Let's get the text safely.
            if let firstResult = results.first {
                print("Transcription Output: \(firstResult.text)")
                return firstResult.text
            }
            print("No transcription results returned.")
            return nil
        } catch {
            print("Transcription failed: \(error)")
            return nil
        }
    }
}
