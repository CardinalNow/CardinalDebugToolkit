//
//  DebugMenuBaseCell.swift
//  CardinalDebugToolkit
//
//  Copyright (c) 2018 Cardinal Solutions (https://www.cardinalsolutions.com/)
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

class DebugMenuInfoCell: DebugMenuBaseCell {
    public override var detailTextLabel: UILabel? {
        return valueLabel
    }

    @IBOutlet var valueLabel: UILabel!

    private var info: String?
    private var shouldResetAfterCopy = false

    // MARK: - lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        shouldResetAfterCopy = false
    }

    // MARK: - public methods

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected, let info = info {
            UIPasteboard.general.string = info

            valueLabel.text = "Copied"
            shouldResetAfterCopy = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.resetAfterCopy()
            })
        }
    }

    func configure(withTitle title: String, info: String?) {
        self.info = info
        titleLabel.text = title
        valueLabel.text = info
    }

    func resetAfterCopy() {
        guard shouldResetAfterCopy else { return }

        shouldResetAfterCopy = false
        valueLabel.text = info
    }
}
