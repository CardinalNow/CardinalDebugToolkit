//
//  DebugLogViewController.swift
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

public class DebugLogViewController: UIViewController {
    @IBOutlet var logTextView: UITextView!
    @IBOutlet var searchBar: UISearchBar!

    var logFileURL: URL?
    private var isFiltered = false

    // MARK: - lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        ]

        updateLogTextViewContent()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let tabBar = tabBarController?.tabBar, !tabBar.isHidden {
            logTextView.contentInset.bottom = tabBar.frame.height
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isBeingDismissed {
            if let tempFileURL = URLForTempLogFile(isFiltered: true) {
                try? FileManager.default.removeItem(at: tempFileURL)
            }
            if let tempFileURL = URLForTempLogFile(isFiltered: false) {
                try? FileManager.default.removeItem(at: tempFileURL)
            }
        }
    }

    // MARK: - private methods

    private func URLForTempLogFile(isFiltered: Bool) -> URL? {
        if let logFileURL = logFileURL {
            let fileName = isFiltered
                ? logFileURL.deletingPathExtension().lastPathComponent + "_filtered.log"
                : logFileURL.lastPathComponent
            return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName)
        } else {
            return nil
        }
    }

    @objc
    private func share() {
        if let logText = logTextView.text, let tempFileURL = URLForTempLogFile(isFiltered: isFiltered) {
            try? logText.write(to: tempFileURL, atomically: true, encoding: .utf8)

            let vc = UIActivityViewController(activityItems: [tempFileURL], applicationActivities: nil)
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            let appDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            vc.setValue("Log file from \(appDisplayName ?? appName ?? "") \(version ?? "") (\(build ?? ""))", forKey: "subject")

            present(vc, animated: true, completion: nil)
        }
    }

    fileprivate func updateLogTextViewContent() {
        if let logFileURL = logFileURL, let text = try? String(contentsOf: logFileURL) {
            if let searchTerm = searchBar.text?.lowercased(), !searchTerm.isEmpty {
                isFiltered = true
                logTextView.text = text.components(separatedBy: .newlines).filter({ $0.lowercased().contains(searchTerm) }).joined(separator: "\n")
            } else {
                isFiltered = false
                logTextView.text = text
            }
        } else {
            isFiltered = false
            logTextView.text = nil
        }
    }
}

// MARK: - UISearchBarDelegate
extension DebugLogViewController: UISearchBarDelegate {
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()

        updateLogTextViewContent()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        updateLogTextViewContent()
    }
}
