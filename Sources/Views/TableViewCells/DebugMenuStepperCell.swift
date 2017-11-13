//
//  DebugMenuStepperCell.swift
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

public class DebugMenuStepperCell: DebugMenuBaseCell {
    @IBOutlet var valueTextField: UITextField!
    @IBOutlet var stepper: UIStepper!

    private lazy var toolbar: UIView = {
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 44.0))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: valueTextField, action: #selector(resignFirstResponder))
        ]

        return toolbar
    }()

    public var itemId: String?
    public weak var delegate: DebugViewControllerDelegate?

    // MARK: - lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()

        valueTextField.inputAccessoryView = toolbar
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        itemId = nil
        valueTextField.text = nil
    }

    // MARK: - public methods

    public func configure(withMenuStepperItem stepperItem: DebugMenuStepperItem) {
        itemId = stepperItem.id
        textLabel?.text = stepperItem.title
        valueTextField.text = String(stepperItem.value)
        stepper.value = stepperItem.value
        stepper.minimumValue = stepperItem.min
        stepper.maximumValue = stepperItem.max
        stepper.stepValue = stepperItem.step
    }

    // MARK: - IBActions

    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        if let text = sender.text, let value = Double(text) {
            stepper.value = value
            if let itemId = itemId {
                delegate?.didChangeStepper(withId: itemId, to: value)
            }
        }
    }

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        valueTextField.text = String(sender.value)
        if let itemId = itemId {
            delegate?.didChangeStepper(withId: itemId, to: sender.value)
        }
    }
}
