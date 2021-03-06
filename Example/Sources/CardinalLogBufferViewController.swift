//
//  CardinalLogBufferViewController.swift
//  CardinalLogger
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

open class CardinalLogBufferViewController: UIViewController {
    public let textView = UITextView()
    open var logBuffer: CardinalLogBuffer?

    // MARK: - lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Copy", style: .plain, target: self, action: #selector(copyData)),
            UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clear)),
        ]

        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        if let logBuffer = logBuffer {
            textView.text = logBuffer.buffer.reversed().joined(separator: "\n")
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nvc = navigationController, nvc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelf))
        }
    }

    // MARK: - open methods

    @objc
    open func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    open func copyData() {
        if !textView.text.isEmpty {
            UIPasteboard.general.string = textView.text
        }
    }

    @objc
    open func clear() {
        textView.text = ""
        logBuffer?.buffer.removeAll()
    }
}
