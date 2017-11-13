//
//  DebugViewController.swift
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

/// Types adopting the `DebugViewControllerDelegate` protocol can be used to handle user interactions
/// with items that are shown in the Debug view.
public protocol DebugViewControllerDelegate: class {
    /// This method is called when an item of type DebugItem and Kind toggle is switched on or off.
    func didToggleItem(withId id: String, to isOn: Bool)
    /// This method is called when an item of type DebugMultiChoiceItem is selected.
    func didToggleChoice(withId id: String, inSectionWithId sectionId: String, to isOn: Bool)
    /// This method is called when an item of type DebugItem and Kind action is selected.
    /// If the return value is of a type that DebugViewController can handle, it will
    /// display the returned data in the appropriate fashion.
    /// - Currently supported types:
    ///   - UIViewController (including UINavigationController)
    ///   - NSAttributedString
    ///   - String
    func didSelectAction(withId id: String) -> Any?
    /// This method is called when an item of type DebugItem and Kind stepper has its value changed.
    func didChangeStepper(withId id: String, to value: Double)
    /// This method is called when an item of type DebugItem and Kind picker has its value changed.
    func didSelectPickerValue(withIndex index: Int, forItemWithId id: String)
}

/// Responsible for displaying the debug interface as defined by section property.
public class DebugViewController: UITableViewController {
    /// Delegate object that handles all user interactions with sections and items.
    /// This property retains object assigned to it.
    public var delegate: DebugViewControllerDelegate?
    /// The user-defined sections that make up the debug interface.
    public var sections: [DebugMenuSection] = []

    public var showBuiltInTools = true

    // MARK: - class methods

    /// Create an instance of this view controller.
    public static func newInstance() -> DebugViewController {
        return DebugToolkitStoryboard.debugViewController()
    }

    // MARK: - lifecycle

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nvc = navigationController, nvc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelf))
        }
    }

    // MARK: - public methods

    /// Call this method after updating the sections property to update the interface.
    public func reloadSections() {
        guard isViewLoaded else { return }

        tableView.reloadData()
    }

    // MARK: - private methods

    @objc
    private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
public extension DebugViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + (showBuiltInTools ? 1 : 0)
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showBuiltInTools && section == sections.count {
            return 3
        }

        return sections[section].items.count
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if showBuiltInTools && section == sections.count {
            return nil
        }

        return sections[section].title
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            cell.delegate = delegate
            cell.configure(withMenuPickerItem: pickerItem)

            returnedCell = cell
        } else if let stepperItem = item as? DebugMenuStepperItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepperCell", for: indexPath) as! DebugMenuStepperCell
            cell.delegate = delegate
            cell.configure(withMenuStepperItem: stepperItem)

            returnedCell = cell
        } else if let subSectionItem = item as? DebugMenuSubSectionItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            cell.textLabel?.text = subSectionItem.title

            returnedCell = cell
        } else if let toggleItem = item as? DebugMenuToggleItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath) as! DebugMenuToggleCell
            cell.delegate = delegate
            cell.configure(withMenuToggleItem: toggleItem)

            returnedCell = cell
        } else {
            assertionFailure("Unhandled menu item type")
            returnedCell = UITableViewCell()
        }

        return returnedCell
    }
}

// MARK: - UITableViewDelegate
public extension DebugViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)

        if showBuiltInTools && indexPath.section == sections.count {
            if indexPath.row == 0 {
                let vc = DebugToolkitStoryboard.logListViewController()
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
                let result = delegate?.didSelectAction(withId: actionItem.id)
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
                    tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Copied"
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    })
                }
            } else if let multiChoiceItem = item as? DebugMenuMultiChoiceItem {
                let section = sections[indexPath.section]
                multiChoiceItem.isSelected = !multiChoiceItem.isSelected
                delegate?.didToggleChoice(withId: multiChoiceItem.id, inSectionWithId: section.id, to: multiChoiceItem.isSelected)
                tableView.reloadSections([indexPath.section], with: .automatic)
            } else if let _ = item as? DebugMenuPickerItem {
                tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
            } else if let _ = item as? DebugMenuStepperItem {

            } else if let subSectionItem = item as? DebugMenuSubSectionItem {
                let vc = DebugToolkitStoryboard.debugViewController()
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
}
