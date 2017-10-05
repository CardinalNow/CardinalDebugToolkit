//
//  DebugViewPickerCell.swift
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 10/5/17.
//

import Foundation
import UIKit

public class DebugViewPickerCell: UITableViewCell {
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

    public override var canBecomeFirstResponder: Bool {
        return true
    }

    public override var inputView: UIView? {
        return pickerView
    }

    public override var inputAccessoryView: UIView? {
        return toolbar
    }

    weak var delegate: DebugViewControllerDelegate?

    public override func awakeFromNib() {
        super.awakeFromNib()

        pickerView.dataSource = self
        pickerView.delegate = self
    }

    public func configure(withItemId itemId: String, title: String, selectedIndex: Int, values: [String]) {
        self.itemId = itemId
        self.values = values

        textLabel?.text = title
        if selectedIndex < values.count {
            detailTextLabel?.text = values[selectedIndex]
        }
    }
}

// MARK: - UIPickerViewDatasource
extension DebugViewPickerCell: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
}

// MARK: - UIPickerViewDelegate
extension DebugViewPickerCell: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row]
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        detailTextLabel?.text = values[row]
        delegate?.didSelectPickerValue(withIndex: row, forItemWithId: itemId)
    }
}
