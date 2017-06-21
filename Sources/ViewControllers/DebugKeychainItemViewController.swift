//
//  DebugKeychainItemViewController.swift
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

public class DebugKeychainItemViewController: UITableViewController {
    public var item: [String: Any] = [:]
    fileprivate var keys: [String] = []

    // MARK: - lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44

        title = item["key"] as? String

        keys = item.keys.sorted()
        if let index = keys.index(of: "class") {
            keys.remove(at: index)
            keys.insert("class", at: 0)
        }
        if let index = keys.index(of: "service") {
            keys.remove(at: index)
            keys.insert("service", at: 0)
        }
        if let index = keys.index(of: "value") {
            keys.remove(at: index)
            keys.insert("value", at: 0)
        }
        if let index = keys.index(of: "key") {
            keys.remove(at: index)
            keys.insert("key", at: 0)
        }
    }
}

// MARK: - UITableViewDataSource
public extension DebugKeychainItemViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys[section]
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "keychainItemPropertyCell", for: indexPath) as! DebugKeychainItemPropertyCell

        let sectionKey = keys[indexPath.section]
        let value = item[keys[indexPath.section]]

        var propertyString: String
        if sectionKey == "value", let value = value as? Data, let unarchivedString = NSKeyedUnarchiver.unarchiveObject(with: value) as? String {
            propertyString = unarchivedString
        } else {
            propertyString = "\(value ?? "")"
        }

        if propertyString.characters.count > 1000 {
            cell.propertyValueLabel.text = String(propertyString.characters.prefix(1000)) + "…"
        } else {
            cell.propertyValueLabel.text = propertyString
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
public extension DebugKeychainItemViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
