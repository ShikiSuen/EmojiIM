import Foundation
import LibEmojiIMPreferences
import PreferencePanes

@objc(Preferences)
@MainActor
public class Preferences: NSPreferencePane, @unchecked Sendable {
  private let prefDelegate = PreferencesDelegate()

  override public func mainViewDidLoad() {
    MainActor.assumeIsolated {
      prefDelegate.loadMainViewThroughMainActor(against: mainView)
    }
  }
}
