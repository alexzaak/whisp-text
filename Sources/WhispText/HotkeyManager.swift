import Cocoa

class HotkeyManager: ObservableObject {
    var onStart: (() -> Void)?
    var onStop: (() -> Void)?
    
    private var monitor: Any?
    private var isRecording = false
    
    func startMonitoring() {
        // Request accessibility permissions implicitly by setting the monitor
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleEvent(event)
        }
    }
    
    func stopMonitoring() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
    
    private func handleEvent(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        // We only trigger when BOTH Fn and Shift are pressed, and no others (like cmd, opt, ctrl).
        // Optionally, one could trigger just on Fn, but the instruction says Fn + Shift.
        let onlyFnShift = flags == [.function, .shift]
        
        if onlyFnShift {
            if !isRecording {
                isRecording = true
                onStart?()
            }
        } else {
            if isRecording {
                isRecording = false
                onStop?()
            }
        }
    }
}
