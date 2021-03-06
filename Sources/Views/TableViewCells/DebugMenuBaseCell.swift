//
//  DebugMenuBaseCell.swift
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

public class DebugMenuBaseCell: UITableViewCell {
    public override var textLabel: UILabel? {
        return titleLabel ?? super.textLabel
    }

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleLabelLeadingConstraint: NSLayoutConstraint!

    // MARK: - lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()

        textLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.minimumScaleFactor = 0.75

        if #available(iOS 11.0, *) {
        } else if let titleLabelLeadingConstraint = titleLabelLeadingConstraint {
            titleLabelLeadingConstraint.isActive = false

            let leadingMargin: CGFloat = (UIScreen.main.bounds.width == 414.0) ? 20.0 : 16.0
            let constraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leadingMargin)
            constraint.isActive = true
            self.titleLabelLeadingConstraint = constraint

            setNeedsLayout()
        }
    }
}
