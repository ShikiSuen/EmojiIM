import Cocoa
@preconcurrency import InputMethodKit
import LibEmojiIM

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
  private var server: IMKServer?

  func applicationDidFinishLaunching(_ notification: Notification) {
    let bundle = Bundle.main
    server = IMKServer(
      name: bundle.infoDictionary?["InputMethodConnectionName"] as? String,
      bundleIdentifier: bundle.bundleIdentifier
    )
  }
}
