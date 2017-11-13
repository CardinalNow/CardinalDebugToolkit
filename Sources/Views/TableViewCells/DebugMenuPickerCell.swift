//
//  DebugMenuPickerCell.swift
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

public class DebugMenuPickerCell: DebugMenuBaseCell {
    public override var detailTextLabel: UILabel? {
        return valueLabel
    }

    public override var canBecomeFirstResponder: Bool {
        return true
    }

    public override var inputView: UIView? {
        return pickerView
    }

    public override var inputAccessoryView: UIView? {
        return toolbar
    }

    @IBOutlet var valueLabel: UILabel!

    private var itemId = ""
    private var values: [String] = []

    private let pickerView = UIPickerView()

    private lazy var toolbar: UIView = {
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 44.0))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        ]

        return toolbar
    }()

    weak var delegate: DebugViewControllerDelegate?

    // MARK: - lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()

        pickerView.dataSource = self
        pickerView.delegate = self
    }

    // MARK: - public methods

    public func configure(withItemId itemId: String, title: String, selectedIndex: Int, values: [String]) {
        self.itemId = itemId
        self.values = values

        textLabel?.text = title
        if selectedIndex < values.count {
            detailTextLabel?.text = values[selectedIndex]
            pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
    }

    public func configure(withMenuPickerItem pickerItem: DebugMenuPickerItem) {
        configure(withItemId: pickerItem.id, title: pickerItem.title, selectedIndex: pickerItem.selectedIndex, values: pickerItem.values)
    }
}

// MARK: - UIPickerViewDatasource
extension DebugMenuPickerCell: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
}

// MARK: - UIPickerViewDelegate
extension DebugMenuPickerCell: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row]
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        detailTextLabel?.text = values[row]
        delegate?.didSelectPickerValue(withIndex: row, forItemWithId: itemId)
    }
}
