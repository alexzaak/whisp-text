import SwiftUI
import AppKit

class HUDManager {
    static let shared = HUDManager()
    private var window: NSWindow?
    private var isVisible = false
    
    func showHUD(text: String) {
        if window == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 100),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .stationary]
            panel.isFloatingPanel = true
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.ignoresMouseEvents = true
            
            self.window = panel
        }
        
        // Update the view
        let overlayView = OverlayView(text: text)
        window?.contentView = NSHostingView(rootView: overlayView)
        
        // Position at bottom center
        if let screen = NSScreen.main {
            let screenRect = screen.frame
            let windowWidth: CGFloat = 600
            let windowHeight: CGFloat = 100
            let rect = NSRect(
                x: (screenRect.width - windowWidth) / 2,
                y: 100, // 100 pixels from bottom
                width: windowWidth,
                height: windowHeight
            )
            window?.setFrame(rect, display: true)
        }
        
        if !isVisible {
            window?.orderFrontRegardless()
            isVisible = true
        }
    }
    
    func updateHUD(text: String) {
        guard isVisible else { return }
        window?.contentView = NSHostingView(rootView: OverlayView(text: text))
    }
    
    func hideHUD() {
        window?.orderOut(nil)
        isVisible = false
    }
}

struct OverlayView: View {
    var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mic.fill")
                .font(.system(size: 20))
                .foregroundColor(.red)
            
            Text(text.isEmpty ? "Listening..." : text)
                .font(.system(size: 20, weight: .medium, design: .default))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.6))
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        )
        .drawingGroup() // Optimize rendering
    }
}
