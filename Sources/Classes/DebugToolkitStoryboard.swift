//
//  DebugViewToggleCell.swift
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

public struct DebugToolkitStoryboard {
    private enum StoryboardIdentifier: String {
        case debugViewController
        case logListViewController
        case logViewController
        case keychainListViewController
        case keychainItemViewController
        case debugDataViewController
        case debugLogBufferViewController
        case userDefaultsListViewController
        case userDefaultsScopeListViewController
    }

    public static func debugViewController() -> DebugViewController {
        return DebugToolkitStoryboard.newInstance().instantiateInitialViewController() as! DebugViewController
    }

    public static func logBufferViewController() -> DebugLogBufferViewController {
        return DebugToolkitStoryboard.newInstance().instantiateViewController(withIdentifier: StoryboardIdentifier.debugLogBufferViewController.rawValue) as! DebugLogBufferViewController
    }

    public static func keychainItemViewController() -> DebugKeychainItemViewController {
        return DebugToolkitStoryboard.newInstance().instantiateViewController(withIdentifier: StoryboardIdentifier.keychainItemViewController.rawValue) as! DebugKeychainItemViewController
    }

    public static func userDefaultsListViewController() -> DebugUserDefaultsListViewController {
        return DebugToolkitStoryboard.newInstance().instantiateViewController(withIdentifier: StoryboardIdentifier.userDefaultsListViewController.rawValue) as! DebugUserDefaultsListViewController
    }

    public static func userDefaultsScopeListViewController() -> DebugUserDefaultsScopeListViewController {
        return DebugToolkitStoryboard.newInstance().instantiateViewController(withIdentifier: StoryboardIdentifier.userDefaultsScopeListViewController.rawValue) as! DebugUserDefaultsScopeListViewController
    }

    public static func logListViewController() -> DebugLogListViewController {
        return DebugToolkitStoryboard.newInstance().instantiateViewController(withIdentifier: StoryboardIdentifier.logListViewController.rawValue) as! DebugLogListViewController
    }

    public static func logViewController() -> DebugLogViewController {
        return DebugToolkitStoryboard.newInstance().instantiateViewController(withIdentifier: StoryboardIdentifier.logViewController.rawValue) as! DebugLogViewController
    }

    public static func keychainListViewController() -> DebugKeychainListViewController {
        return DebugToolkitStoryboard.newInstance().instantiateViewController(withIdentifier: StoryboardIdentifier.keychainListViewController.rawValue) as! DebugKeychainListViewController
    }

    public static func dataViewController() -> DebugDataViewController {
        return DebugToolkitStoryboard.newInstance().instantiateViewController(withIdentifier: StoryboardIdentifier.debugDataViewController.rawValue) as! DebugDataViewController
    }

    public static func newInstance() -> UIStoryboard {
        let resourceBundle: Bundle
        // Cocoapods
        if let frameworkBundle = Bundle(identifier: "org.cocoapods.CardinalDebugToolkit") {
            resourceBundle = Bundle(url: frameworkBundle.url(forResource: "CardinalDebugToolkit-Storyboards", withExtension: "bundle")!)!
        } else {
            resourceBundle = Bundle(identifier: "com.cardinalsolutions.CardinalDebugToolkit")!
        }

        return UIStoryboard(name: "Debug", bundle: resourceBundle)
    }
}
