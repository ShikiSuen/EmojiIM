// (c) 2017 and onwards Mzp (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import AppKit
import Carbon.HIToolbox
import CoreFoundation
import Foundation
import LibEmojiIMSharedImpl

@objc(PreferencesDelegate)
public class PreferencesDelegate: NSObject, @unchecked Sendable {
  override public init() {
    Process.consoleLog("[EmojiIM][Preferences] PreferencesDelegate initialized.")
  }

  private let store = SettingStore()
  private lazy var keyboardLayouts: [TISInputSource]? = TISInputSource.keyboardLayouts()?.filter { $0.scriptCode == 0 }

  public func loadMainViewThroughMainActor(against mainView: NSView) {
    Process.consoleLog("[EmojiIM][Preferences] loadMainViewThroughMainActor called, starting execution.")
    let keyboardLabel = NSTextField().with {
      $0.stringValue = "Keyboard:"
      $0.drawsBackground = false
      $0.isBordered = false
      $0.isEditable = false
      $0.isSelectable = false
      $0.alignment = .right
    }
    let keyboard = NSPopUpButton().with {
      for layout in keyboardLayouts ?? [] { $0.addItem(withTitle: layout.localizedName) }
      if let i = keyboardLayouts?.firstIndex(where: { $0.inputSourceID == store.keyboardLayoutID }) {
        $0.selectItem(at: i)
      }
      $0.target = self
      $0.action = #selector(keyboardSelectionChanged(_:))
    }
    let revisionLabel = NSTextField().with {
      $0.stringValue = "Revision:"
      $0.drawsBackground = false
      $0.isBordered = false
      $0.isEditable = false
      $0.isSelectable = false
      $0.alignment = .right
    }
    let revision = NSTextField().with {
      $0.stringValue = Bundle.kRevision
      $0.drawsBackground = false
      $0.isBordered = false
      $0.isEditable = false
      $0.isSelectable = false
    }
    let builtDateLabel = NSTextField().with {
      $0.stringValue = "Built date:"
      $0.drawsBackground = false
      $0.isBordered = false
      $0.isEditable = false
      $0.isSelectable = false
      $0.alignment = .right
    }
    let builtDate = NSTextField().with {
      $0.stringValue = Bundle.kBuiltDate
      $0.drawsBackground = false
      $0.isBordered = false
      $0.isEditable = false
      $0.isSelectable = false
    }

    for v in [keyboardLabel, keyboard, revisionLabel, revision, builtDateLabel, builtDate] {
      v.translatesAutoresizingMaskIntoConstraints = false
      mainView.addSubview(v)
    }
    NSLayoutConstraint.activate([
      keyboardLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
      keyboardLabel.widthAnchor.constraint(equalToConstant: 60),
      keyboard.leadingAnchor.constraint(equalTo: keyboardLabel.trailingAnchor, constant: 10),
      keyboard.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20),
      builtDateLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
      builtDateLabel.widthAnchor.constraint(equalToConstant: 60),
      builtDate.leadingAnchor.constraint(equalTo: builtDateLabel.trailingAnchor, constant: 10),
      revisionLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
      revisionLabel.widthAnchor.constraint(equalToConstant: 60),
      revision.leadingAnchor.constraint(equalTo: revisionLabel.trailingAnchor, constant: 10),
      keyboardLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
      keyboardLabel.heightAnchor.constraint(equalToConstant: 16),
      keyboard.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
      builtDateLabel.topAnchor.constraint(equalTo: keyboardLabel.bottomAnchor, constant: 10),
      builtDateLabel.heightAnchor.constraint(equalToConstant: 16),
      builtDate.topAnchor.constraint(equalTo: keyboard.bottomAnchor, constant: 10),
      revisionLabel.topAnchor.constraint(equalTo: builtDateLabel.bottomAnchor, constant: 10),
      revisionLabel.heightAnchor.constraint(equalToConstant: 16),
      revision.topAnchor.constraint(equalTo: builtDate.bottomAnchor, constant: 10),
    ])
  }

  @objc private func keyboardSelectionChanged(_ sender: NSPopUpButton) {
    if let layout = keyboardLayouts?[sender.indexOfSelectedItem] {
      store.keyboardLayoutID = layout.inputSourceID
      store.save()
    }
  }
}
