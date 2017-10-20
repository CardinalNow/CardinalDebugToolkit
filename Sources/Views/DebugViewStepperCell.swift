//
//  DebugViewToggleCell.swift
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

class DebugViewStepperCell: UITableViewCell {
    public override var textLabel: UILabel? {
        return titleLabel
    }

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var valueTextField: UITextField!
    @IBOutlet var stepper: UIStepper!

    public var itemId: String?
    public weak var delegate: DebugViewControllerDelegate?

    // MARK: - lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 11.0, *) {
        } else {
            titleLabelLeadingConstraint.isActive = false
            let constraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0)
            constraint.isActive = true
            titleLabelLeadingConstraint = constraint
        }

        valueTextField.addTarget(self, action: #selector(textFieldValueChanged(sender:)), for: .editingChanged)
        stepper.addTarget(self, action: #selector(stepperValueChanged(sender:)), for: .primaryActionTriggered)
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        itemId = nil
        valueTextField.text = nil
    }

    // MARK: - public methods

    // MARK: - private methods

    @objc
    private func textFieldValueChanged(sender: UITextField) {
        if let text = sender.text, let value = Double(text) {
            stepper.value = value
            if let itemId = itemId {
                delegate?.didChangeStepper(withId: itemId, to: value)
            }
        }
    }

    @objc
    private func stepperValueChanged(sender: UIStepper) {
        valueTextField.text = String(sender.value)
        if let itemId = itemId {
            delegate?.didChangeStepper(withId: itemId, to: sender.value)
        }
    }
}
