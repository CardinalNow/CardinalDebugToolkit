//
//  DebugUserDefaultsScopeListViewController.swift
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

public class DebugUserDefaultsScopeListViewController: UITableViewController {
    private var persistentDomains = persistentUserDefaultsDomains()
    private var volatileDomains = volatileUserDefaultsDomains()
    var selectedScope: UserDefaultsScope = .all
    weak var listViewController: DebugUserDefaultsListViewController?

    // MARK: - lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - IBActions
}

// MARK: - UITableViewDataSource
extension DebugUserDefaultsScopeListViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return persistentDomains.count
        case 2: return volatileDomains.count
        default: return 0
        }
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userDefaultScopeCell", for: indexPath)

        cell.accessoryType = .none
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = "All"
                if case .all = selectedScope {
                    cell.accessoryType = .checkmark
                }
            } else {
                cell.textLabel?.text = "Global"
                if case .global = selectedScope {
                    cell.accessoryType = .checkmark
                }
            }
        case 1:
            let domain = persistentDomains[indexPath.row]
            cell.textLabel?.text = domain
            if case .persistent(let selectedDomain) = selectedScope, selectedDomain == domain {
                cell.accessoryType = .checkmark
            }
        case 2:
            let domain = volatileDomains[indexPath.row]
            cell.textLabel?.text = domain
            if case .volatile(let selectedDomain) = selectedScope, selectedDomain == domain {
                cell.accessoryType = .checkmark
            }
        default: break
        }

        return cell
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Persistent Domains"
        case 2: return "Volatile Domains"
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension DebugUserDefaultsScopeListViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                listViewController?.scope = .all
            } else {
                listViewController?.scope = .global
            }
        case 1:
            listViewController?.scope = .persistent(persistentDomains[indexPath.row])
        case 2:
            listViewController?.scope = .volatile(volatileDomains[indexPath.row])
        default: break
        }

        navigationController?.popViewController(animated: true)
    }
}
