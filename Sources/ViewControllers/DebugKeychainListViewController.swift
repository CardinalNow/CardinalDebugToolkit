//
//  DebugKeychainListViewController.swift
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
import KeychainAccess

public class DebugKeychainListViewController: UITableViewController {
    // MARK: - lifecycle

    public var items: [[String: Any]] = []

    public override func viewDidLoad() {
        super.viewDidLoad()

        items = Keychain.allItems(.genericPassword) + Keychain.allItems(.internetPassword)
    }
}

// MARK: - UITableViewDataSource
public extension DebugKeychainListViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "keychainEntryCell", for: indexPath)
        if let key = item["key"] as? String {
            cell.textLabel?.text = key
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        } else {
            cell.textLabel?.text = "(no key)"
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 17.0)
        }

        cell.detailTextLabel?.text = "\(item["class"] ?? "") - \(item["service"] ?? "")"

        return cell
    }
}

// MARK: - UITableViewDelegate
public extension DebugKeychainListViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = DebugToolkitStoryboard.keychainItemViewController()
        vc.item = items[indexPath.row]

        show(vc, sender: self)
    }
}
