//
//  MyDebugMenuViewController.swift
//  iOS-Example
//
//  Created by Robin Kunde on 11/20/17.
//  Copyright © 2017 Cardinal Solutions. All rights reserved.
//

import CardinalDebugToolkit
import Foundation
import UserNotifications

class MyDebugMenuViewController: DebugMenuViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        updateDebugSections()
    }

    private func updateDebugSections() {
        let featureSwitch1 = UserDefaults.standard.bool(forKey: "featureSwitch1")
        let stepper1 = UserDefaults.standard.double(forKey: "stepper1")

        let multiChoice1Selected = UserDefaults.standard.bool(forKey: "mc1")
        let multiChoice2Selected = UserDefaults.standard.bool(forKey: "mc2")

        let selectedPickerIndex = UserDefaults.standard.integer(forKey: "picker1")

        let deviceToken = (UIApplication.shared.delegate as! AppDelegate).deviceToken

        sections = [
            DebugMenuSection(id: "exampleToggles", title: "Example Toggles", items: [
                DebugMenuToggleItem(id: "featureSwitch1", title: "Feature Switch", isOn: featureSwitch1),
                DebugMenuToggleItem(id: "featureSwitch2", title: "Switch backed by UserDefaults key", userDefaultKey: "featureSwitch2"),
            ]),
            DebugMenuSection(id: "exampleOther", title: "Other", items: [
                DebugMenuStepperItem(id: "stepper1", title: "Analytics batch length (seconds)", value: stepper1, min: 0.0, max: 300.0, step: 10.0),
                DebugMenuStepperItem(id: "stepper2", title: "Stepper backed by UserDefaults", userDefaultKey: "stepper2", min: 0.0, max: 300.0, step: 10.0),
                DebugMenuPickerItem(id: "picker1", title: "API environment", values: ["Production", "Staging", "Development"], selectedIndex: selectedPickerIndex),
                DebugMenuSubSectionItem(id: "subMenu1", title: "Sub Menu with 2 actions", items: [
                    DebugMenuActionItem(id: "subSectionAction1", title: "Other action"),
                    DebugMenuActionItem(id: "subSectionAction2", title: "Yet another action"),
                ]),
                DebugMenuSubSectionItem(id: "subMenu2", title: "Sub Menu with 2 sections", sections: [
                    DebugMenuSection(id: "subSection1", title: "Sometimes you have so many actions", items: [
                        DebugMenuActionItem(id: "subSectionAction3", title: "You need to put them"),
                    ]),
                    DebugMenuSection(id: "subSection1", title: "On their own screen", items: [
                        DebugMenuActionItem(id: "subSectionAction3", title: "Just to keep organized"),
                    ]),
                ])
            ]),
            DebugMenuMultiChoiceSection(id: "multiChoiceSection1", title: "Multiple Choice Section", items: [
                DebugMenuMultiChoiceItem(id: "mc1", title: "Item 1", isSelected: multiChoice1Selected),
                DebugMenuMultiChoiceItem(id: "mc2", title: "Item 2", isSelected: multiChoice2Selected),
            ]),
            DebugMenuSection(id: "simpleData", title: "Simple Data (tap to copy)", items: [
                DebugMenuInfoItem(id: "userId", title: "User ID", info: NSUUID().uuidString),
                DebugMenuInfoItem(id: "pushToken", title: "APNS Device Token", info: deviceToken),
            ]),
            DebugMenuSection(id: "actions", title: "Actions", items: [
                DebugMenuActionItem(id: "requestPush", title: "Request push notification permission"),
                DebugMenuActionItem(id: "crash", title: "Crash the app"),
                DebugMenuActionItem(id: "viewString", title: "View String Data"),
                DebugMenuActionItem(id: "viewAttrStr", title: "View Attributed String Data"),
                DebugMenuActionItem(id: "viewVC", title: "View VC"),
                DebugMenuActionItem(id: "viewNVC", title: "View NVC"),
            ]),
        ]
    }

    // MARK: - DebugMenuDelegate

    override func debugMenu(_ debugMenu: DebugMenuViewController, changedMultiChoiceWithId id: String, inSectionWithId sectionId: String, to isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: id)
    }

    override func debugMenu(_ debugMenu: DebugMenuViewController, changedPickerWithId id: String, toIndex index: Int) {
        UserDefaults.standard.set(index, forKey: "picker1")
    }

    override func debugMenu(_ debugMenu: DebugMenuViewController, changedStepperWithId id: String, to value: Double) {
        switch id {
        case "stepper1":
            UserDefaults.standard.set(value, forKey: "stepper1")
        default: break
        }
    }

    override func debugMenu(_ debugMenu: DebugMenuViewController, changedToggleWithId id: String, to isOn: Bool) {
        switch id {
        case "featureSwitch1":
            UserDefaults.standard.set(isOn, forKey: "featureSwitch1")
        default: break
        }
    }

    override func debugMenu(_ debugMenu: DebugMenuViewController, selectedActionWithId id: String) -> Any? {
        switch id {
        case "crash":
            abort()
        case "requestPush":
            let center  = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        case "subSectionAction1", "subSectionAction2", "subSectionAction3", "subSectionAction4":
            break
        case "viewString":
            return "Example string\nbroken up\nover\nmultiple lines"
        case "viewAttrStr":
            return NSAttributedString(string: "Example string in a large, bold font", attributes: [
                .font: UIFont.boldSystemFont(ofSize: 32)
                ])
        case "viewVC":
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "exampleViewController")
        case "viewNVC":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "exampleViewController")
            let nvc = UINavigationController(rootViewController: vc)

            return nvc
        default:
            assertionFailure("Unimplemented action")
            return nil
        }

        return nil
    }

    override func logFileUrlsForDebugMenu(_ debugMenu: DebugMenuViewController) -> [URL] {
        return CardinalLogger.consoleLogFileURLs().reversed()
    }
}
