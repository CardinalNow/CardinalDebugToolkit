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
        tableView.estimatedRowHeight = 64

        title = item["key"] as? String

        keys = item.keys.sorted()
        if let index = keys.index(of: "generic") {
            keys.remove(at: index)
            keys.insert("generic", at: 0)
        }
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
        if let index = keys.index(of: "account") {
            keys.remove(at: index)
            keys.insert("account", at: 0)
        }
    }

    private func stringRepresentation(key: String, value: Any, full: Bool) -> String {
        var propertyString: String
        if let data = value as? Data {
            if let unarchivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String {
                propertyString = unarchivedString
            } else if !data.isEmpty, let string = String(data: data, encoding: .utf8) {
                propertyString = string
            } else if key == "sha1" {
                propertyString = data.map({ String(format: "%02hhx", $0) }).joined()
            } else {
                if full {
                    propertyString = (data as NSData).description
                } else {
                    propertyString = data.description
                }
            }
        } else if let date = value as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            propertyString = formatter.string(from: date)
        } else {
            propertyString = "\(value)"
        }

        return propertyString
    }
}

// MARK: - UITableViewDataSource
public extension DebugKeychainItemViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "keychainItemPropertyCell", for: indexPath) as! DebugKeychainItemPropertyCell

        let key = keys[indexPath.row]
        cell.textLabel?.text = key

        if let value = item[key] {
            let propertyString = stringRepresentation(key: key, value: value, full: false)

            if propertyString.count > 128 {
                cell.detailTextLabel?.text = String(propertyString.prefix(128)) + "…"
            } else {
                cell.detailTextLabel?.text = propertyString
            }
        } else {
            cell.detailTextLabel?.text = nil
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
public extension DebugKeychainItemViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let key = keys[indexPath.row]

        let vc = DebugToolkitStoryboard.dataViewController()
        if let value = item[key] {
            vc.dataString = stringRepresentation(key: key, value: value, full: true)
        }

        show(vc, sender: self)
    }
}
