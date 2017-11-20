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

public class DebugKeychainListViewController: UITableViewController {
    // MARK: - lifecycle

    private var sectionTypes: [ItemClass] = []
    public var sections: [[[String: Any]]] = []

    public override func viewDidLoad() {
        super.viewDidLoad()

        for itemClass in [ItemClass.certificate, ItemClass.genericPassword, ItemClass.identity, ItemClass.internetPassword, ItemClass.key] {
            let items = Keychain.allItems(forItemClass: itemClass)
            if !items.isEmpty {
                sectionTypes.append(itemClass)
                sections.append(items)
            }
        }
    }
}

// MARK: - UITableViewDataSource
public extension DebugKeychainListViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTypes[section].description
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section][indexPath.row]
        let sectionType = sectionTypes[indexPath.section]

        let cell = tableView.dequeueReusableCell(withIdentifier: "keychainEntryCell", for: indexPath)

        var title: [String] = []
        if sectionType == .key {
            if let value = item["label"] as? String, !value.isEmpty {
                title.append(value)
            }
        } else {
            for key in ["generic", "account"] {
                if let value = item[key] as? String {
                    if !value.isEmpty, !title.contains(value) {
                        title.append(value)
                    }
                } else if let valueData = item[key] as? Data, let value = String(data: valueData, encoding: .utf8) {
                    if !value.isEmpty, !title.contains(value) {
                        title.append(value)
                    }
                }
            }
        }

        if title.isEmpty {
            cell.textLabel?.text = "(no key)"
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 17.0)
        } else {
            cell.textLabel?.text = title.joined(separator: " - ")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        }

        cell.detailTextLabel?.text = "\(item["service"] ?? "")"

        return cell
    }
}

// MARK: - UITableViewDelegate
public extension DebugKeychainListViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = DebugToolkitStoryboard.keychainItemViewController()
        vc.item = sections[indexPath.section][indexPath.row]

        show(vc, sender: self)
    }
}
