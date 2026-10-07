// Prints the id of the first on-screen window owned by the named process, for
// `screencapture -l` (see site_app_test.dart). Usage: swift window_id.swift Lexify
import CoreGraphics
import Foundation

let owner = CommandLine.arguments.dropFirst().first ?? ""
let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
for w in windows where w[kCGWindowOwnerName as String] as? String == owner
    && w[kCGWindowLayer as String] as? Int == 0 {
    print(w[kCGWindowNumber as String] as? Int ?? 0)
    exit(0)
}
exit(1)
