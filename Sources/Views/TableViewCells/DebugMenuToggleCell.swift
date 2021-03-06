//
//  DebugMenuToggleCell.swift
//  CardinalDebugToolkit
//
//  Copyright (c) 2017 Cardinal Solutions (https://www.cardinalsolutions.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import UIKit

public class DebugMenuToggleCell: DebugMenuBaseCell {
    private var toggleView = UISwitch()

    private var toggleItem: DebugMenuToggleItem?

    public weak var debugMenuViewController: DebugMenuViewController?
    public weak var delegate: DebugMenuDelegate?

    // MARK: - lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()

        toggleView.addTarget(self, action: #selector(switchToggled(_:)), for: .primaryActionTriggered)
        accessoryView = toggleView
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        toggleItem = nil
        toggleView.isOn = false
    }

    // MARK: - public methods

    public func configure(withMenuToggleItem toggleItem: DebugMenuToggleItem) {
        self.toggleItem = toggleItem
        textLabel?.text = toggleItem.title

        switch toggleItem.toggleType {
        case .normal(let isOn):
            toggleView.isOn = isOn
        case .userDefault(let key):
            toggleView.isOn = UserDefaults.standard.bool(forKey: key)
        }
    }

    // MARK: - private methods

    @objc
    private func switchToggled(_ sender: UISwitch) {
        guard let toggleItem = toggleItem else { return }

        switch toggleItem.toggleType {
        case .normal: break
        case .userDefault(let key):
            UserDefaults.standard.set(toggleView.isOn, forKey: key)
        }
        if let debugMenuViewController = debugMenuViewController {
            delegate?.debugMenu(debugMenuViewController, changedToggleWithId: toggleItem.id, to: toggleView.isOn)
        }
    }
}
