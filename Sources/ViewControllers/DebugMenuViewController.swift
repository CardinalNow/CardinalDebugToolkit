//
//  DebugMenuViewController.swift
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

/// Classes adopting this protocol can be used to handle
/// user interactions with items that are shown in the Debug menu.
public protocol DebugMenuDelegate: class {
    /// This method is called when an item of type DebugMultiChoiceItem is selected.
    func debugMenu(_ debugMenu: DebugMenuViewController, changedMultiChoiceWithId id: String, inSectionWithId sectionId: String, to isOn: Bool)
    /// This method is called when an item of type DebugItem and Kind picker has its value changed.
    func debugMenu(_ debugMenu: DebugMenuViewController, changedPickerWithId id: String, toIndex index: Int)
    /// This method is called when an item of type DebugItem and Kind stepper has its value changed.
    func debugMenu(_ debugMenu: DebugMenuViewController, changedStepperWithId id: String, to value: Double)
    /// This method is called when an item of type DebugItem and Kind toggle is switched on or off.
    func debugMenu(_ debugMenu: DebugMenuViewController, changedToggleWithId id: String, to isOn: Bool)
    /// This method is called when an item of type DebugItem and Kind action is selected.
    /// If the return value is of a type that DebugViewController can handle, it will
    /// display the returned data in the appropriate fashion.
    /// - Currently supported types:
    ///   - UIViewController (including UINavigationController)
    ///   - NSAttributedString
    ///   - String
    func debugMenu(_ debugMenu: DebugMenuViewController, selectedActionWithId id: String) -> Any?

    func logFileUrlsForDebugMenu(_ debugMenu: DebugMenuViewController) -> [URL]
}

/// Responsible for displaying the debug interface as defined by section property.
open class DebugMenuViewController: UITableViewController, DebugMenuDelegate {
    /// Delegate object that handles user interactions with sections and items.
    open weak var delegate: DebugMenuDelegate?
    /// The user-defined sections that make up the debug interface.
    open var sections: [DebugMenuSection] = []
    /// Determines whether built-in tools will be added to the generated menu.
    open var showBuiltInTools = true

    // MARK: - initializer

    public init() {
        super.init(style: .grouped)

        delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        delegate = self
    }

    // MARK: - lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        extendedLayoutIncludesOpaqueBars = true

        let bundle = DebugToolkitStoryboard.bundle()
        tableView.register(UINib(nibName: "DebugMenuActionCell", bundle: bundle), forCellReuseIdentifier: "actionCell")
        tableView.register(UINib(nibName: "DebugMenuInfoCell", bundle: bundle), forCellReuseIdentifier: "infoCell")
        tableView.register(UINib(nibName: "DebugMenuPickerCell", bundle: bundle), forCellReuseIdentifier: "pickerCell")
        tableView.register(UINib(nibName: "DebugMenuSelectionCell", bundle: bundle), forCellReuseIdentifier: "selectionCell")
        tableView.register(UINib(nibName: "DebugMenuStepperCell", bundle: bundle), forCellReuseIdentifier: "stepperCell")
        tableView.register(UINib(nibName: "DebugMenuToggleCell", bundle: bundle), forCellReuseIdentifier: "toggleCell")
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nvc = navigationController, nvc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelf))
        }
    }

    // MARK: - public methods

    /// Call this method after updating the sections property to update the interface.
    open func reloadSections() {
        guard isViewLoaded else { return }

        tableView.reloadData()
    }

    // MARK: - private methods

    @objc
    private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + (showBuiltInTools ? 1 : 0)
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showBuiltInTools && section == sections.count {
            return 3
        }

        return sections[section].items.count
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if showBuiltInTools && section == sections.count {
            return nil
        }

        return sections[section].title
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: DebugMenuItem
        if showBuiltInTools && indexPath.section == sections.count {
            if indexPath.row == 0 {
                item = DebugMenuActionItem(id: "view_debug_log", title: "View Debug Logs")
            } else if indexPath.row == 1 {
                item = DebugMenuActionItem(id: "view_user_defaults", title: "View UserDefaults")
            } else {
                item = DebugMenuActionItem(id: "view_keychain", title: "View Keychain Items")
            }
        } else {
            item = sections[indexPath.section].items[indexPath.row]
        }

        let returnedCell: UITableViewCell
        if let actionItem = item as? DebugMenuActionItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            cell.textLabel?.text = actionItem.title

            returnedCell = cell
        } else if let infoItem = item as? DebugMenuInfoItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            cell.textLabel?.text = infoItem.title
            cell.detailTextLabel?.text = infoItem.info

            returnedCell = cell
        } else if let multiChoiceItem = item as? DebugMenuMultiChoiceItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath)
            cell.textLabel?.text = multiChoiceItem.title
            cell.accessoryType = multiChoiceItem.isSelected ? .checkmark : .none

            returnedCell = cell
        } else if let pickerItem = item as? DebugMenuPickerItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! DebugMenuPickerCell
            cell.debugMenuViewController = self
            cell.delegate = delegate
            cell.configure(withMenuPickerItem: pickerItem)

            returnedCell = cell
        } else if let stepperItem = item as? DebugMenuStepperItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepperCell", for: indexPath) as! DebugMenuStepperCell
            cell.debugMenuViewController = self
            cell.delegate = delegate
            cell.configure(withMenuStepperItem: stepperItem)

            returnedCell = cell
        } else if let subSectionItem = item as? DebugMenuSubSectionItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            cell.textLabel?.text = subSectionItem.title

            returnedCell = cell
        } else if let toggleItem = item as? DebugMenuToggleItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath) as! DebugMenuToggleCell
            cell.debugMenuViewController = self
            cell.delegate = delegate
            cell.configure(withMenuToggleItem: toggleItem)

            returnedCell = cell
        } else {
            assertionFailure("Unhandled menu item type")
            returnedCell = UITableViewCell()
        }

        return returnedCell
    }

    // MARK: - UITableViewDelegate

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)

        if showBuiltInTools && indexPath.section == sections.count {
            if indexPath.row == 0 {
                let vc = DebugToolkitStoryboard.logListViewController()
                vc.debugMenuViewController = self
                vc.delegate = self
                show(vc, sender: self)
            } else if indexPath.row == 1 {
                let vc = DebugToolkitStoryboard.userDefaultsListViewController()
                show(vc, sender: self)
            } else {
                let vc = DebugToolkitStoryboard.keychainListViewController()
                show(vc, sender: self)
            }
        } else {
            let item = sections[indexPath.section].items[indexPath.row]

            if let actionItem = item as? DebugMenuActionItem {
                let result = delegate?.debugMenu(self, selectedActionWithId: actionItem.id)
                switch result {
                case .some(let viewController as UIViewController):
                    show(viewController, sender: self)
                case .some(let data):
                    let vc = DebugToolkitStoryboard.dataViewController()

                    if let attributedString = data as? NSAttributedString {
                        vc.dataAttributedString = attributedString
                    } else if let str = data as? String {
                        vc.dataString = str
                    } else {
                        vc.dataString = "\(data)"
                    }
                    show(vc, sender: self)
                default:
                    break
                }
            } else if let infoItem = item as? DebugMenuInfoItem {
                if let copyString = infoItem.info {
                    UIPasteboard.general.string = copyString
                    // TODO: do this in a way that's compatible with cell reuse
                    tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Copied"
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    })
                }
            } else if let multiChoiceItem = item as? DebugMenuMultiChoiceItem {
                let section = sections[indexPath.section]
                multiChoiceItem.isSelected = !multiChoiceItem.isSelected
                delegate?.debugMenu(self, changedMultiChoiceWithId: multiChoiceItem.id, inSectionWithId: section.id, to: multiChoiceItem.isSelected)
                tableView.reloadSections([indexPath.section], with: .automatic)
            } else if let _ = item as? DebugMenuPickerItem {
                tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
            } else if let _ = item as? DebugMenuStepperItem {

            } else if let subSectionItem = item as? DebugMenuSubSectionItem {
                let vc = DebugMenuViewController()
                vc.delegate = delegate
                vc.showBuiltInTools = false
                vc.sections = subSectionItem.sections
                vc.title = subSectionItem.title

                show(vc, sender: self)
            } else if let _ = item as? DebugMenuToggleItem {
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - DebugMenuDelegate

    open func debugMenu(_ debugMenu: DebugMenuViewController, changedMultiChoiceWithId id: String, inSectionWithId sectionId: String, to isOn: Bool) {
    }

    open func debugMenu(_ debugMenu: DebugMenuViewController, changedPickerWithId id: String, toIndex index: Int) {
    }

    open func debugMenu(_ debugMenu: DebugMenuViewController, changedStepperWithId id: String, to value: Double) {
    }

    open func debugMenu(_ debugMenu: DebugMenuViewController, changedToggleWithId id: String, to isOn: Bool) {
    }

    open func debugMenu(_ debugMenu: DebugMenuViewController, selectedActionWithId id: String) -> Any? {
        return nil
    }

    open func logFileUrlsForDebugMenu(_ debugMenu: DebugMenuViewController) -> [URL] {
        return []
    }
}
