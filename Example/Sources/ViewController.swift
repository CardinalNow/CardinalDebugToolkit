//
//  ViewController.swift
//  CardinalDebugToolkitExample
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

import UIKit
import CardinalDebugToolkit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func presentDebugPanelTapped(_ sender: UIButton) {
        let dbgVC = DebugViewController.newInstance()
        dbgVC.delegate = DebugHandler(debugController: dbgVC)

        let nvc = UINavigationController(rootViewController: dbgVC)
        nvc.navigationBar.isTranslucent = false
        show(nvc, sender: self)
    }

    @IBAction func pushDebugPanelTapped(_ sender: UIButton) {
        let dbgVC = DebugViewController.newInstance()
        dbgVC.delegate = DebugHandler(debugController: dbgVC)

        show(dbgVC, sender: self)
    }

    @IBAction func toggleDebugOverlayTapped(_ sender: UIButton) {
        (UIApplication.shared.delegate as! AppDelegate).debugOverlay.toggle()
    }
}

class DebugHandler: DebugViewControllerDelegate {
    unowned var debugController: DebugViewController

    private var checkboxSetting = true

    init(debugController: DebugViewController) {
        self.debugController = debugController

        updateDebugSections()
    }

    private func updateDebugSections() {
        let featureSwitch1 = UserDefaults.standard.bool(forKey: "featureSwitch1")
        let stepper1 = UserDefaults.standard.double(forKey: "stepper1")

        let multiChoice1Selected = UserDefaults.standard.bool(forKey: "mc1")
        let multiChoice2Selected = UserDefaults.standard.bool(forKey: "mc2")

        let selectedPickerIndex = UserDefaults.standard.integer(forKey: "picker1")

        let deviceToken = (UIApplication.shared.delegate as! AppDelegate).deviceToken

        debugController.sections = [
            DebugMenuSection(id: "exampleToggles", title: "Example Toggles", items: [
                DebugMenuToggleItem(id: "featureSwitch1", title: "Feature Switch", isOn: featureSwitch1),
                DebugMenuToggleItem(id: "featureSwitch2", title: "Switch backed by UserDefaults key", userDefaultKey: "featureSwitch2"),
            ]),
            DebugMenuSection(id: "exampleOther", title: "Other", items: [
                DebugMenuStepperItem(id: "stepper1", title: "Analytics batch length (seconds)", value: stepper1, min: 0.0, max: 300.0, step: 10.0),
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
                DebugMenuInfoItem(id: "userId", title: "User ID", info: "0000001"),
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

        debugController.reloadSections()
    }

    func changedMultiChoice(withId id: String, inSectionWithId sectionId: String, to isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: id)
    }

    func changedPicker(withId id: String, toIndex index: Int) {
        UserDefaults.standard.set(index, forKey: "picker1")
    }

    func changedStepper(withId id: String, to value: Double) {
        UserDefaults.standard.set(value, forKey: id)
    }

    func changedToggle(withId id: String, to isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: id)
    }

    func selectedAction(withId id: String) -> Any? {
        switch id {
        case "crash":
            abort()
        case "requestPush":
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
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
}
