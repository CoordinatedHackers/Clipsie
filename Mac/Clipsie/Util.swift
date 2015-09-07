import Foundation
import ServiceManagement

let HasShownFirstLaunchHelpKey = "HasShownFirstLaunchHelp"

private let LauncherBundleID = "com.coordinatedhackers.Clipsie-Launcher"

func setLaunchAtLogin(launch: Bool) {
    SMLoginItemSetEnabled(LauncherBundleID, launch ? 1 : 0)
}

func getLaunchAtLogin() -> Bool {
    if let jobs = SMCopyAllJobDictionaries(kSMDomainUserLaunchd)?.takeRetainedValue() as? [[String: AnyObject]] {
        for job in jobs {
            if job["Label"] as? String == LauncherBundleID {
                if (job["OnDemand"] as? NSNumber)?.boolValue == true {
                    return true
                }
            }
        }
    }
    return false
}