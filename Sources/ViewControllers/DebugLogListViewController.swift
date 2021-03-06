//
//  DebugLogListViewController.swift
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

public class DebugLogListViewController: UITableViewController {
    private var logFileURLs: [URL] = []
    private let filesizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file

        return formatter
    }()
    internal weak var debugMenuViewController: DebugMenuViewController?
    internal weak var delegate: DebugMenuDelegate?

    // MARK: - lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let debugMenuViewController = debugMenuViewController {
            logFileURLs = delegate?.logFileUrlsForDebugMenu(debugMenuViewController) ?? []
        }

        if !logFileURLs.isEmpty {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
            ]
        }
    }

    // MARK: - private methods

    @objc
    private func share() {
        let vc = UIActivityViewController(activityItems: logFileURLs, applicationActivities: nil)
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        let appDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        vc.setValue("Log file from \(appDisplayName ?? appName ?? "") \(version ?? "") (\(build ?? ""))", forKey: "subject")

        present(vc, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
public extension DebugLogListViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logFileURLs.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let url = logFileURLs[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        cell.textLabel?.text = url.lastPathComponent
        if let filesize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize {
            cell.detailTextLabel?.text = filesizeFormatter.string(fromByteCount: Int64(filesize))
        } else {
            cell.detailTextLabel?.text = nil
        }
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

// MARK: - UITableViewDelegate
public extension DebugLogListViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = DebugToolkitStoryboard.logViewController()
        vc.logFileURL = logFileURLs[indexPath.row]

        show(vc, sender: self)
    }
}
