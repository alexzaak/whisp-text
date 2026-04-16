import Cocoa
import CoreGraphics

class TextInjector {
    static func paste(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // 1. Copy text to pasteboard
        let pasteboard = NSPasteboard.general
        // preserve the old pasteboard content if we wanted, but for now we just overwrite
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // 2. Simulate Command + V
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Virtual key code for 'v' is 0x09
        let cmdVDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        cmdVDown?.flags = .maskCommand
        
        let cmdVUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        cmdVUp?.flags = .maskCommand
        
        // Add a small delay to ensure the pasteboard is updated before the paste event is handled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            cmdVDown?.post(tap: .cghidEventTap)
            cmdVUp?.post(tap: .cghidEventTap)
        }
    }
}
