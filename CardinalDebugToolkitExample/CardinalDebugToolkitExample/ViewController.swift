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
        show(nvc, sender: self)
    }

    @IBAction func pushDebugPanelTapped(_ sender: UIButton) {
        let dbgVC = DebugViewController.newInstance()
        dbgVC.delegate = DebugHandler(debugController: dbgVC)

        show(dbgVC, sender: self)
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
        let toggle1 = UserDefaults.standard.bool(forKey: "toggle1")
        let toggle2 = UserDefaults.standard.bool(forKey: "toggle2")

        let selectedItemId = UserDefaults.standard.string(forKey: "multiChoice")

        debugController.sections = [
            DebugSection(title: "Toggles", items: [
                DebugItem(id: "toggle1", kind: .toggle(toggle1), title: "Toggle 1"),
                DebugItem(id: "toggle2", kind: .toggle(toggle2), title: "Toggle 2")
            ]),
            DebugMultiChoiceSection(id: "multiChoice", title: "Mutliple Choice", items: [
                DebugMultiChoiceItem(id: "mc1", title: "Choice 1"),
                DebugMultiChoiceItem(id: "mc2", title: "Choice 2")
            ], selectedItemId: selectedItemId),
            DebugSection(title: "Simple Data", items: [
                DebugItem(id: "userID", kind: .info("000000001"), title: "User ID"),
            ]),
            DebugSection(title: "Actions", items: [
                DebugItem(id: "crash", kind: .action, title: "Crash the app"),
                DebugItem(id: "viewString", kind: .action, title: "View String Data"),
                DebugItem(id: "viewAttrStr", kind: .action, title: "View Attributed String Data"),
                DebugItem(id: "viewVC", kind: .action, title: "View VC"),
                DebugItem(id: "viewNVC", kind: .action, title: "View NVC")
            ])
        ]

        debugController.reloadSections()
    }

    func didToggleItem(withId id: String, to isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: id)
    }

    func didSelectChoice(withId id: String, inSectionWithId sectionId: String) {
        UserDefaults.standard.set(id, forKey: sectionId)
    }

    func didSelectAction(withId id: String) -> Any? {
        switch id {
        case "crash":
            abort()
        case "viewString":
            return "Example string\nbroken up\nover\nmultiple lines"
        case "viewAttrStr":
            return NSAttributedString(string: "Example string in a large, bold font", attributes: [
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 32)
            ])
        case "viewVC":
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "exampleViewController")
        case "viewNVC":
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "exampleViewController")
            let nvc = UINavigationController(rootViewController: vc)

            return nvc
        default:
            return nil
        }

        return nil
    }
}
