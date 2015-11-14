import Cocoa

class HelpWindowController: NSWindowController, NSWindowDelegate {
    
    var holdSelf: HelpWindowController? = nil
    
    var helpViewController: HelpViewController! {
        get { return self.contentViewController as! HelpViewController }
    }
    
    override func awakeFromNib() {
        holdSelf = self
    }
    
    func focus() {
        NSApp.setActivationPolicy(.Regular)
        NSApp.activateIgnoringOtherApps(true)
        window!.makeKeyAndOrderFront(nil)
    }
    
    func windowWillClose(notification: NSNotification) {
        holdSelf = nil
        NSApp.setActivationPolicy(.Prohibited)
    }
    
}

class HelpViewController: NSViewController {
    
    @IBOutlet weak var startAtLoginCheckbox: NSButton! {
        didSet {
            startAtLoginCheckbox.state = getLaunchAtLogin() ? NSOnState : NSOffState
        }
    }
    
    @IBAction func quit(sender: AnyObject!) {
        NSApplication.sharedApplication().terminate(sender)
    }
    
    @IBAction func emailUs(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "mailto:team@coordinatedhackers.com?subject=Clipsie")!)
    }
    
    @IBAction func startAtLoginChanged(sender: NSButton!) {
        if sender.state == NSOffState {
            setLaunchAtLogin(false)
        }
    }
    
    @IBAction func dismiss(sender: AnyObject!) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: HasShownFirstLaunchHelpKey)
        defaults.synchronize()
        
        if startAtLoginCheckbox.state == NSOnState {
            setLaunchAtLogin(true)
        }
        
        view.window?.close()
    }
    
}