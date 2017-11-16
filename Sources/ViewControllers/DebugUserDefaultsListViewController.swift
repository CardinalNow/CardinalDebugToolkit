//
//  DebugUserDefaultsListViewController.swift
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

public class DebugUserDefaultsListViewController: UITableViewController {
    @IBOutlet var searchBar: UISearchBar!
    private var defaults: [String: Any] = [:]
    private var defaultsKeys: [String] = []
    var scope: UserDefaultsScope = .all {
        didSet {
            searchBar.text = nil
        }
    }

    // MARK: - lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Domains", style: .plain, target: self, action: #selector(showDomains))
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refresh()
    }

    private func refresh() {
        switch scope {
        case .all:
            defaults = UserDefaults.standard.dictionaryRepresentation()
        case .global:
            defaults = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain) ?? [:]
        case .persistent(let domain):
            defaults = UserDefaults.standard.persistentDomain(forName: domain) ?? [:]
        case .volatile(let domain):
            defaults = UserDefaults.standard.volatileDomain(forName: domain)
        }
        defaultsKeys = Array(defaults.keys)
        defaultsKeys.sort()

        applyFilter()
    }

    private func applyFilter() {
        if let searchTerm = searchBar.text?.lowercased(), !searchTerm.isEmpty {
            defaultsKeys = defaultsKeys.filter({ $0.lowercased().contains(searchTerm) })
        }

        tableView.reloadData()
    }

    @objc
    private func showDomains() {
        searchBar.resignFirstResponder()

        let vc = DebugToolkitStoryboard.userDefaultsScopeListViewController()
        vc.listViewController = self
        vc.selectedScope = scope

        show(vc, sender: self)
    }

    // MARK: - IBActions
}

// MARK: - UITableViewDataSource
extension DebugUserDefaultsListViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultsKeys.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userDefaultCell", for: indexPath) as! DebugUserDefaultItemCell

        cell.textLabel?.text = defaultsKeys[indexPath.row]
        if let object = defaults[defaultsKeys[indexPath.row]] {
            switch stringRepresentation(value: object, fullDescription: false) {
            case .full(_, let description):
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17.0)
                cell.detailTextLabel?.text = description
            case .summary(let description):
                cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 17.0)
                cell.detailTextLabel?.text = description
            }
        } else {
            cell.detailTextLabel?.text = nil
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension DebugUserDefaultsListViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = DebugToolkitStoryboard.dataViewController()
        if let object = defaults[defaultsKeys[indexPath.row]] {
            switch stringRepresentation(value: object, fullDescription: true) {
            case .full(let type, let description):
                vc.dataDescription = "Key: \(defaultsKeys[indexPath.row])\nType: \(type)"
                vc.dataString = description
            case .summary(_):
                assertionFailure("This case should not occur")
                break
            }
        }

        show(vc, sender: self)
    }
}

extension DebugUserDefaultsListViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()

        applyFilter()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        applyFilter()
    }
}
