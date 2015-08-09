import Cocoa

class HelpWindowController: NSWindowController, NSWindowDelegate {
    
    var holdSelf: HelpWindowController? = nil
    
    override func awakeFromNib() {
        holdSelf = self
    }
    
    func focus() {
        window!.makeKeyAndOrderFront(nil)
        (NSApp as! NSApplication).setActivationPolicy(.Regular)
        (NSApp as! NSApplication).activateIgnoringOtherApps(true)
    }
    
    func windowWillClose(notification: NSNotification) {
        holdSelf = nil
        (NSApp as! NSApplication).setActivationPolicy(.Prohibited)
    }
    
}

class HelpViewController: NSViewController {
    
    @IBAction func emailUs(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "mailto:team@coordinatedhackers.com?subject=Clipsie")!)
    }
    
}