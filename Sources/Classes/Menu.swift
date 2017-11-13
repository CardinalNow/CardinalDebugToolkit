//
//  Menu.swift
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 11/9/17.
//  Copyright © 2017 Cardinal Solutions. All rights reserved.
//

import Foundation

/// Debug section type for general sections.
public class DebugMenuSection {
    /// Identifier of this section.
    public let id: String
    /// Title of this section.
    public let title: String
    /// The items that will appear in this section.
    public let items: [DebugMenuItem]

    /// Creates an instance with the specified `id`, `title`, and `items`.
    ///
    /// - Parameters:
    ///   - id: The section identifier.
    ///   - title: The section title.
    ///   - items: The items that will appear in this section.
    public init(id: String, title: String, items: [DebugMenuItem]) {
        self.id = id
        self.title = title
        self.items = items
    }
}

/// Debug section type for multiple-choice style sections. At most one item can be selected at once.
public class DebugMenuMultiChoiceSection: DebugMenuSection {
    /// Creates an instance with the specified `id`, `title`, and `items`.
    ///
    /// - Parameters:
    ///   - id: The identifier.
    ///   - title: The section title.
    ///   - items: The items.
    public init(id: String, title: String, items: [DebugMenuMultiChoiceItem]) {
        super.init(id: id, title: title, items: items)
    }
}

/// General debug item type.
public class DebugMenuItem {
    /// Identifier of this item. The identifier will be passed to the delegate
    /// methods when this item is selected.
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

public class DebugMenuActionItem: DebugMenuItem {
}

public class DebugMenuInfoItem: DebugMenuItem {
    public let info: String?

    public init(id: String, title: String, info: String?) {
        self.info = info

        super.init(id: id, title: title)
    }
}

/// Debug item type for section of `DebugMenuMultiChoiceSection` type.
public class DebugMenuMultiChoiceItem: DebugMenuItem {
    /// Whether or not this item is selected.
    var isSelected: Bool

    /// Creates an instance with the specified `id`, `title`, and `isSelected`.
    ///
    /// - Parameters:
    ///   - id: The item identifier.
    ///   - title: The item title.
    ///   - isSelected: The item selection state.
    public init(id: String, title: String, isSelected: Bool) {
        self.isSelected = isSelected

        super.init(id: id, title: title)
    }
}

public class DebugMenuPickerItem: DebugMenuItem {
    public let values: [String]
    public var selectedIndex: Int

    public init(id: String, title: String, values: [String], selectedIndex: Int) {
        self.values = values
        self.selectedIndex = selectedIndex

        super.init(id: id, title: title)
    }
}

public class DebugMenuStepperItem: DebugMenuItem {
    public var value: Double
    public let min: Double
    public let max: Double
    public let step: Double

    public init(id: String, title: String, value: Double, min: Double, max: Double, step: Double) {
        self.value = value
        self.min = min
        self.max = max
        self.step = step

        super.init(id: id, title: title)
    }
}

public class DebugMenuSubSectionItem: DebugMenuItem {
    public let sections: [DebugMenuSection]

    public init(id: String, title: String, items: [DebugMenuItem]) {
        self.sections = [DebugMenuSection(id: id, title: "", items: items)]

        super.init(id: id, title: title)
    }

    public init(id: String, title: String, sections: [DebugMenuSection]) {
        self.sections = sections

        super.init(id: id, title: title)
    }
}

public class DebugMenuToggleItem: DebugMenuItem {
    public enum ToggleType {
        case normal(Bool)
        case userDefault(String)
    }
    public var toggleType: ToggleType

    public init(id: String, title: String, isOn: Bool) {
        self.toggleType = .normal(isOn)

        super.init(id: id, title: title)
    }

    public init(id: String, title: String, userDefaultKey: String) {
        self.toggleType = .userDefault(userDefaultKey)

        super.init(id: id, title: title)
    }
}
