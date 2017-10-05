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


/// Types adopting `DebugSectionProtocol` can be used to define section in the
/// Debug view.
public protocol DebugSectionProtocol {
    var title: String { get }
    var items: [DebugItemProtocol] { get }
}


/// Types adopting the `DebugItemProtocol` can be used to define items in the
/// Debug view sections.
public protocol DebugItemProtocol {
    var id: String { get }
    var title: String { get }
}


/// Debug section type for general sections.
public struct DebugSection: DebugSectionProtocol {
    /// Title of this section.
    public let title: String
    /// The items that will appear in this section.
    public let items: [DebugItemProtocol]

    /// Creates an instance with the specified `title` and `items`.
    ///
    /// - Parameters:
    ///   - title: The section title.
    ///   - items: The items that will appear in this section.
    public init(title: String, items: [DebugItem]) {
        self.title = title
        self.items = items
    }
}

/// General debug item type.
public struct DebugItem: DebugItemProtocol {
    public enum Kind {
        case action
        case info(String?)
        case picker(Int, [String])
        case stepper(Double, Double, Double, Double)
        case toggle(Bool)
    }

    /// Identifier of this item. The identifier will be passed to the delegate 
    /// methods when this item is selected.
    public let id: String
    /// The item kind determines how this item is rendered and which delegate methods
    /// are invoked when it is selected.
    public let kind: Kind
    /// Title of this item in the Debug view.
    public let title: String


    /// Creates an instance with the specified `id`, `kind`, and `title`.
    ///
    /// - Parameters:
    ///   - id: The identifier.
    ///   - kind: The item kind.
    ///   - title: The item title.
    public init(id: String, kind: Kind, title: String) {
        self.id = id
        self.kind = kind
        self.title = title
    }

    public init(stepperWithId id: String, title: String, value: Double, min: Double, max: Double, step: Double) {
        self.id = id
        self.kind = .stepper(value, min, max, step)
        self.title = title
    }

    public init(pickerWithId id: String, title: String, currentIndex: Int, values: [String]) {
        self.id = id
        self.kind = .picker(currentIndex, values)
        self.title = title
    }
}

/// Debug section type for multiple-choice style sections. At most one item can be selected at once.
public struct DebugMultiChoiceSection: DebugSectionProtocol {
    /// Identifier of this section. The identifier will be passed to the delegate
    /// methods when an item in this section is selected.
    public let id: String
    /// Title of this section.
    public let title: String
    /// The items that will appear in this section.
    public let items: [DebugItemProtocol]
    /// The identifier of the currently selected item. To select no item, set this property to
    /// nil.
    public var selectedItemId: String?

    /// Creates an instance with the specified `id`, `title`, `items`, and `selectedItemId`.
    ///
    /// - Parameters:
    ///   - id: The identifier.
    ///   - title: The section title.
    ///   - items: The items.
    ///   - selectedItemId: The identifier of the currently selected item. Pass `nil` to select no item.
    public init(id: String, title: String, items: [DebugMultiChoiceItem], selectedItemId: String?) {
        self.id = id
        self.title = title
        self.items = items
        self.selectedItemId = selectedItemId
    }
}

/// Debug item type for section of `DebugMultiChoiceSection` type.
public struct DebugMultiChoiceItem: DebugItemProtocol {
    /// Identifier of this item. The identifier will be passed to the delegate
    /// methods this item is selected.
    public let id: String
    /// Title of this item in the Debug view.
    public let title: String

    /// Creates an instance with the specified `id` and `title`.
    ///
    /// - Parameters:
    ///   - id: The identifier.
    ///   - title: The item title.
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

/// Types adopting the `DebugViewControllerDelegate` protocol can be used to handle user interactions
/// with items that are shown in the Debug view.
public protocol DebugViewControllerDelegate: class {
    /// This method is called when an item of type DebugItem and Kind toggle is switched on or off.
    func didToggleItem(withId id: String, to isOn: Bool)
    /// This method is called when an item of type DebugMultiChoiceItem is selected.
    func didSelectChoice(withId id: String, inSectionWithId sectionId: String)
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
    public var sections: [DebugSectionProtocol] = []

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
        return sections.count + 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections.count {
            return 2
        }

        return sections[section].items.count
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == sections.count {
            return nil
        }

        return sections[section].title
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: DebugItemProtocol
        if indexPath.section == sections.count {
            if indexPath.row == 0 {
                item = DebugItem(id: "view_debug_log", kind: .action, title: "View Debug Log")
            } else {
                item = DebugItem(id: "view_keychain", kind: .action, title: "View Keychain Items")
            }
        } else {
            item = sections[indexPath.section].items[indexPath.row]
        }

        if let item = item as? DebugItem {
            switch item.kind {
            case .action:
                let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
                cell.textLabel?.text = item.title

                return cell
            case .info(let infoString):
                let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
                cell.textLabel?.text = item.title
                cell.detailTextLabel?.text = infoString

                return cell
            case .picker(let currentIndex, let values):
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! DebugViewPickerCell
                cell.delegate = delegate
                cell.configure(withItemId: item.id, title: item.title, selectedIndex: currentIndex, values: values)

                return cell
            case .stepper(let value, let min, let max, let step):
                let cell = tableView.dequeueReusableCell(withIdentifier: "stepperCell", for: indexPath) as! DebugViewStepperCell
                cell.itemId = item.id
                cell.delegate = delegate
                cell.textLabel?.text = item.title
                cell.valueTextField.text = String(value)
                cell.stepper.value = value
                cell.stepper.minimumValue = min
                cell.stepper.maximumValue = max
                cell.stepper.stepValue = step

                return cell
            case .toggle(let isOn):
                let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath) as! DebugViewToggleCell
                cell.itemId = item.id
                cell.delegate = delegate
                cell.textLabel?.text = item.title
                cell.toggleView.isOn = isOn

                return cell
            }
        } else {
            let item = item as! DebugMultiChoiceItem
            let section = sections[indexPath.section] as! DebugMultiChoiceSection

            let cell = tableView.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath)
            cell.textLabel?.text = item.title
            cell.accessoryType = (section.selectedItemId == item.id) ? .checkmark : .none

            return cell
        }
    }
}

// MARK: - UITableViewDelegate
public extension DebugViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)

        if indexPath.section == sections.count {
            if indexPath.row == 0 {
                let vc = DebugLogListViewController()
                show(vc, sender: self)
            } else {
                let vc = DebugToolkitStoryboard.keychainListViewController()
                show(vc, sender: self)
            }
        } else {
            let item = sections[indexPath.section].items[indexPath.row]

            if let item = item as? DebugItem {
                switch item.kind {
                case .action:
                    let result = delegate?.didSelectAction(withId: item.id)
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
                case .info(let infoString):
                    if let copyString = infoString {
                        UIPasteboard.general.string = copyString
                        tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Copied"
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        })
                    }
                case .picker(_, _):
                    tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
                case .stepper(_):
                    break
                case .toggle(_):
                    break
                }
            } else if let item = item as? DebugMultiChoiceItem {
                var section = (sections[indexPath.section] as! DebugMultiChoiceSection)
                section.selectedItemId = item.id
                sections[indexPath.section] = section

                delegate?.didSelectChoice(withId: item.id, inSectionWithId: section.id)

                tableView.reloadSections([indexPath.section], with: .automatic)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
