import Cocoa

let parent_bundle = NSBundle.mainBundle().bundleURL.URLByDeletingLastPathComponent!.URLByDeletingLastPathComponent!.URLByDeletingLastPathComponent!.URLByDeletingLastPathComponent!

NSWorkspace.sharedWorkspace().launchApplicationAtURL(parent_bundle, options: NSWorkspaceLaunchOptions.WithoutActivation, configuration: [:], error: nil)