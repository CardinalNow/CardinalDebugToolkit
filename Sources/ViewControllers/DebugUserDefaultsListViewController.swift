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

public enum UserDefaultsScope {
    case all
    case global
    case persistent(String)
    case volatile(String)
}

public class DebugUserDefaultsListViewController: UITableViewController {
    @IBOutlet var searchBar: UISearchBar!
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
            defaultsKeys = Array(UserDefaults.standard.dictionaryRepresentation().keys)
        case .global:
            let defaults = UserDefaults(suiteName: "global")?.dictionaryRepresentation() ?? [:]
            defaultsKeys = Array(defaults.keys)
        case .persistent(let domain):
            let defaults = UserDefaults.standard.persistentDomain(forName: domain) ?? [:]
            defaultsKeys = Array(defaults.keys)
        case .volatile(let domain):
            defaultsKeys = Array(UserDefaults.standard.volatileDomain(forName: domain).keys)
        }
        if let searchTerm = searchBar.text, !searchTerm.isEmpty {
            defaultsKeys = defaultsKeys.filter({ $0.contains(searchTerm) })
        }
        defaultsKeys.sort()

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "userDefaultCell", for: indexPath) as! DebugUserDefaultCell

        cell.textLabel?.text = defaultsKeys[indexPath.row]
        if let object = UserDefaults.standard.object(forKey: defaultsKeys[indexPath.row]) {
            switch stringRepresentation(value: object, fullDescription: false) {
            case .full(_, let description):
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17.0)
                cell.detailTextLabel?.text = description
            case .summary(let description):
                cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 17.0)
                cell.detailTextLabel?.text = description
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension DebugUserDefaultsListViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = DebugToolkitStoryboard.dataViewController()
        if let object = UserDefaults.standard.object(forKey: defaultsKeys[indexPath.row]) {
            switch stringRepresentation(value: object, fullDescription: true) {
            case .full(let type, let description):
                vc.dataString = "\(type):\n\(description)"
            case .summary(_): break
            }
        }

        show(vc, sender: self)
    }
}

extension DebugUserDefaultsListViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        refresh()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()

        refresh()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
