import Foundation
import AVFoundation

class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    
    private let engine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var isEngineRunning = false
    
    // Whisper needs 16kHz float arrays
    private let targetSampleRate: Double = 16000.0
    private var converter: AVAudioConverter?
    private var targetFormat: AVAudioFormat?
    
    // Buffer to hold frames before sending them out
    private var audioBuffer = [Float]()
    
    func startRecording() throws {
        let node = engine.inputNode
        self.inputNode = node
        
        // Setup formats
        let inputFormat = node.outputFormat(forBus: 0)
        guard let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                               sampleRate: targetSampleRate,
                                               channels: 1,
                                               interleaved: false) else {
            throw NSError(domain: "AudioRecorder", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create target audio format"])
        }
        self.targetFormat = outputFormat
        
        self.converter = AVAudioConverter(from: inputFormat, to: outputFormat)
        
        node.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] (buffer, time) in
            self?.process(buffer: buffer)
        }
        
        try engine.start()
        isEngineRunning = true
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func stopRecording() -> [Float] {
        if let node = inputNode {
            node.removeTap(onBus: 0)
        }
        if isEngineRunning {
            engine.stop()
            isEngineRunning = false
        }
        DispatchQueue.main.async {
            self.isRecording = false
        }
        
        let frames = audioBuffer
        audioBuffer.removeAll() // Clear buffer for next recording
        return frames
    }
    
    func getCurrentBuffer() -> [Float] {
        return audioBuffer
    }
    
    private func process(buffer: AVAudioPCMBuffer) {
        guard let targetFormat = targetFormat, let converter = converter else { return }
        
        // Calculate the capacity of the output buffer
        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * targetFormat.sampleRate / buffer.format.sampleRate)
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else { return }
        outputBuffer.frameLength = capacity
        
        // Perform conversion
        var error: NSError?
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)
        if let error = error {
            print("Audio conversion error: \(error)")
        }
        
        // Extract array
        guard let channelData = outputBuffer.floatChannelData else { return }
        let channelDataValue = channelData.pointee
        let frameLength = Int(outputBuffer.frameLength)
        
        let array = Array(UnsafeBufferPointer(start: channelDataValue, count: frameLength))
        
        DispatchQueue.main.async {
            self.audioBuffer.append(contentsOf: array)
        }
    }
}
