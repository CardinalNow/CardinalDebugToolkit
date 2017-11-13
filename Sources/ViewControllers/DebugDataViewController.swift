//
//  DebugDataViewController.swift
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
import MobileCoreServices

public class DebugDataViewController: UIViewController {
    @IBOutlet var dataTypeLabel: UILabel!
    @IBOutlet var borderView: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewTopConstraint: NSLayoutConstraint!

    var dataType: String?
    var dataString: String?
    var dataAttributedString: NSAttributedString?

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Copy", style: .plain, target: self, action: #selector(copyData))

        if let dataType = dataType {
            dataTypeLabel.text = "Data type: \(dataType)"
        } else {
            dataTypeLabel.isHidden = true
            borderView.isHidden = true

            textViewTopConstraint.isActive = false
            textViewTopConstraint = textView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
            textViewTopConstraint.isActive = true
        }

        if let dataAttributedString = dataAttributedString {
            textView.attributedText = dataAttributedString
        } else {
            textView.text = dataString
        }
    }

    @objc
    private func copyData() {
        if let dataAttributedString = dataAttributedString {
            do {
            #if swift(>=3.2)
                let rtf = try dataAttributedString.data(
                    from: NSMakeRange(0, dataAttributedString.length),
                    documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
                )
            #else
                let rtf = try dataAttributedString.data(
                    from: NSMakeRange(0, dataAttributedString.length),
                    documentAttributes: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType]
                )
            #endif
                if let encodedString = NSString(data: rtf, encoding: String.Encoding.utf8.rawValue) {
                    UIPasteboard.general.items = [[
                        kUTTypeRTF as String: encodedString,
                        kUTTypeUTF8PlainText as String: dataAttributedString.string
                    ]]
                }
            } catch {}
        } else if let dataString = dataString {
            UIPasteboard.general.string = dataString
        }
    }
}
