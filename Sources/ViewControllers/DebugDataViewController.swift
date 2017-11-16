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
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var borderView: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewTopConstraint: NSLayoutConstraint!

    var dataDescription: String?
    var dataString: String?
    var dataAttributedString: NSAttributedString?

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonTapped))

        if let dataDescription = dataDescription {
            descriptionLabel.text = dataDescription
        } else {
            descriptionLabel.isHidden = true
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
    private func actionButtonTapped() {
        let activityItems: [Any]
        if let dataAttributedString = dataAttributedString {
            let attrString = NSMutableAttributedString(string: "")
            if let dataDescription = dataDescription {
                attrString.append(NSAttributedString(string: dataDescription))
                attrString.append(NSAttributedString(string: "\n"))
            }
            attrString.append(dataAttributedString)

            activityItems = [attrString]
        } else if var dataString = dataString {
            if let dataDescription = dataDescription {
                dataString = dataDescription + "\n" + dataString
            }

            activityItems = [dataString]
        } else {
            return
        }

        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        let appDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        vc.setValue("Data from \(appDisplayName ?? appName ?? "") \(version ?? "") (\(build ?? ""))", forKey: "subject")

        present(vc, animated: true, completion: nil)
    }
}
