//
//  DebugViewStepperCell.swift
//  Pods
//
//  Created by Robin Kunde on 8/18/17.
//
//

import Foundation

class DebugViewStepperCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueTextField: UITextField!
    @IBOutlet var stepper: UIStepper!

    public var itemId: String?

    public weak var delegate: DebugViewControllerDelegate?

    public override var textLabel: UILabel? {
        return titleLabel
    }

    // MARK: - lifecycle

    public override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        itemId = nil
        valueTextField.text = nil
    }

    // MARK: - public methods

    public override func awakeFromNib() {
        super.awakeFromNib()

        valueTextField.addTarget(self, action: #selector(textFieldValueChanged(sender:)), for: .editingChanged)
        stepper.addTarget(self, action: #selector(stepperValueChanged(sender:)), for: .primaryActionTriggered)
    }

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
