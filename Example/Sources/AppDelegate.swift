//
//  AppDelegate.swift
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let debugOverlay = DebugOverlay()
    let debugOverlayDelegate = DbgOveralayDelegate()

    var deviceToken = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        try? Log.pruneConsoleLogFiles(maxNum: 4)

        let _ = Log.startLoggingConsoleToFile()
        NSLog("test")

        Log.shared.filteredLogBuffers.append(FilteredLogBuffer(tag: "test"))
        Log.shared.critical("Test 1", tag: "test")
        Log.shared.critical("Test 2", tag: "test")

        //
        populateKeychain()
        populateUserDefaults()

        //
        debugOverlay.delegate = debugOverlayDelegate

        return true
    }

    private func populateKeychain() {
        var query: [String: Any] = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): "testString",
            String(kSecValueData): "testValue".data(using: .utf8)!,
            String(kSecAttrService): Bundle.main.bundleIdentifier!,
        ]
        SecItemAdd(query as CFDictionary, nil)

        query = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): "testArray",
            String(kSecValueData): NSKeyedArchiver.archivedData(withRootObject: NSArray(array: ["testEntry"])),
            String(kSecAttrService): Bundle.main.bundleIdentifier!,
        ]
        SecItemAdd(query as CFDictionary, nil)

        query = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): "testDict",
            String(kSecValueData): NSKeyedArchiver.archivedData(withRootObject: NSDictionary(dictionary: ["testKey": "testValue"])),
            String(kSecAttrService): Bundle.main.bundleIdentifier!,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func populateUserDefaults() {
        let defaults = UserDefaults.standard

        defaults.register(defaults: ["testDefault": true])
        defaults.set(false, forKey: "testDefault")
        defaults.set(true, forKey: "testBool")
        defaults.set(true, forKey: "testSuperLongKeyThatWillTakeUpALotOfSpaceAndShouldBeTruncatedOrWrap")
        defaults.set(-100, forKey: "testInt")
        defaults.set(NSArray(array: ["testEntry"]), forKey: "testArray")
        defaults.set(NSDictionary(dictionary: ["testKey": "testValue"]), forKey: "testDict")
        defaults.set(Date(), forKey: "testDate")
        defaults.set(URL(string: "https://www.apple.com/")!, forKey: "testURL")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
    }
}

class DbgOveralayDelegate: DebugOverlayDelegate {
    var debugOverlayActionItems: [DebugOverlayActionItem] {
        return [
            DebugOverlayActionItem(id: "filteredLog", title: "Show log buffer")
        ]
    }

    func debugOverlayShouldDisplayHideAction(_ overlay: DebugOverlay) -> Bool {
        return true
    }

    func debugOverlay(_ overlay: DebugOverlay, selectedActionWithId id: String) -> UIViewController? {
        if id == "filteredLog" {
            let vc = DebugToolkitStoryboard.logBufferViewController()
            vc.filteredLogBuffer = Log.shared.filteredLogBuffers.first
            let nvc = UINavigationController(rootViewController: vc)

            return nvc
        }

        return nil
    }
}
