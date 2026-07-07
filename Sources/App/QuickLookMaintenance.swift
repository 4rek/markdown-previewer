import Foundation
import CoreServices

/// Best-effort helpers that keep the Quick Look extension healthy across installs
/// and updates, so users never have to run `qlmanage` by hand.
///
/// This shells out to `qlmanage`/`lsregister`, which requires the container app
/// to run outside the App Sandbox. The preview *extension* itself stays sandboxed.
enum QuickLookMaintenance {
    private static let lsregister =
        "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

    /// Full activation, run off the main thread: register this copy of the app,
    /// drop any stale duplicate registrations from old/other copies, then refresh
    /// Quick Look so the extension is live immediately.
    static func activateInBackground() {
        DispatchQueue.global(qos: .utility).async {
            resetLog()
            log("activate: start; self=\(Bundle.main.bundlePath)")
            registerSelf()
            removeStaleRegistrations()
            refresh()
            log("activate: done")
        }
    }

    private static var logURL: URL {
        URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent("Library/Logs/MarkdownPreviewer-maintenance.log")
    }

    /// Start each launch with a fresh log so the file stays small and always
    /// reflects the most recent activation.
    private static func resetLog() {
        try? Data().write(to: logURL)
    }

    private static func log(_ message: String) {
        guard let data = (message + "\n").data(using: .utf8) else { return }
        if let handle = try? FileHandle(forWritingTo: logURL) {
            handle.seekToEndOfFile(); handle.write(data); try? handle.close()
        } else {
            try? data.write(to: logURL)
        }
    }

    /// Reset Quick Look's cache. Safe to call anytime; used by the manual
    /// "Refresh Preview Cache" button too.
    static func refresh() {
        run("/usr/bin/qlmanage", ["-r"])
        run("/usr/bin/qlmanage", ["-r", "cache"])
    }

    private static func registerSelf() {
        let ok = run(lsregister, ["-f", Bundle.main.bundlePath])
        log("registerSelf -> \(ok)")
    }

    /// Unregister any *other* on-disk copies of this app so the system doesn't
    /// show duplicate Quick Look extensions (a common outcome of updating or of
    /// leaving an old copy in Downloads). Only LaunchServices is touched — no
    /// files are deleted.
    private static func removeStaleRegistrations() {
        guard let bundleID = Bundle.main.bundleIdentifier else { log("stale: no bundleID"); return }
        let current = Bundle.main.bundleURL.standardizedFileURL
        let copies = registeredCopies(of: bundleID)
        log("stale: bundleID=\(bundleID) copies=\(copies.count) current=\(current.path)")
        for url in copies where url.standardizedFileURL != current {
            let ok = run(lsregister, ["-u", url.path])
            log("stale: unregister \(url.path) -> \(ok)")
        }
    }

    private static func registeredCopies(of bundleID: String) -> [URL] {
        guard let copies = LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?
            .takeRetainedValue() as? [URL] else { return [] }
        return copies
    }

    @discardableResult
    private static func run(_ launchPath: String, _ arguments: [String]) -> Bool {
        guard FileManager.default.isExecutableFile(atPath: launchPath) else { return false }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
