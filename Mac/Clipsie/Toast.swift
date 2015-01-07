import Cocoa

class Toast {
    
    class ToastWindow: NSWindow {
        override var canBecomeKeyWindow: Bool {
            get { return false }
        }
    }
    
    class ToastTextView: NSTextField {
        
        override init() {
            super.init(frame: CGRectZero)
            editable = false
            drawsBackground = false
            font = NSFont.systemFontOfSize(50)
            textColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.9)
            bordered = false
            bezeled = false
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    }
    
    class ToastView: NSView {
        
        let textView = ToastTextView()
        var margin: CGFloat = 0
        
        override init() {
            super.init(frame: CGRectZero)
            addSubview(textView)
            
            wantsLayer = true
            layer!.backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9).CGColor
            layer!.cornerRadius = 10
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        func sizeToFit() {
            textView.sizeToFit()
            textView.frame = CGRect(origin: CGPoint(x: margin, y: margin), size: textView.frame.size)
            frame = CGRect(origin: frame.origin, size: textView.frame.rectByInsetting(dx: -margin, dy: -margin).size)
            
        }
    }
    
    class PresentationRunner: NSObject, NSAnimationDelegate {
        
        var holdSelf: PresentationRunner? = nil
        let animation: NSViewAnimation
        
        init(window: NSWindow, duration: NSTimeInterval) {
            animation = NSViewAnimation(viewAnimations: [([
                NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect,
                NSViewAnimationTargetKey: window,
                ])])
            super.init()
            holdSelf = self
            
            animation.duration = duration
            animation.delegate = self
            animation.startAnimation()
        }
        
        
        func animationDidEnd(animation: NSAnimation) {
            holdSelf = nil
        }
    }
    
    let window = ToastWindow(
        contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
        styleMask: NSBorderlessWindowMask, backing: .Buffered, defer: true
    )
    
    let view = ToastView()
    
    init(_ text: String) {
        view.textView.stringValue = text
        view.margin = 20
        view.sizeToFit()
        
        window.setContentBorderThickness(0, forEdge: NSMinXEdge | NSMinYEdge | NSMaxXEdge | NSMaxYEdge)
        window.setFrame(view.frame, display: true)
        window.level = kCGStatusWindowLevelKey
        window.ignoresMouseEvents = true
        window.backgroundColor = NSColor.clearColor()
        window.opaque = false
        window.contentView = view
    }
    
    func present(hold: NSTimeInterval, _ fade: NSTimeInterval) {
        window.orderFront(self)
        window.center()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(hold * NSTimeInterval(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            PresentationRunner(window: self.window, duration: fade)
            return
        }
    }
}