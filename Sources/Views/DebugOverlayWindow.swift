//
//  DebugLogBufferViewController.swift
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

public struct DebugOverlayAction {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public protocol DebugOverlayDelegate: class {
    func actions() -> [DebugOverlayAction]
    func didSelectAction(withId id: String) -> UIViewController?
}

public class DebugOverlayWindow: UIWindow {
    public weak static var delegate: DebugOverlayDelegate?
    public static var showHideAction = true
    public static var toolbarBackgroundColor: UIColor?
    public static var toolbarTintColor: UIColor?

    private static var window: DebugOverlayWindow?

    private let overlayViewController = DebugOverlayViewController()

    // MARK: - static methods

    public static func show() {
        if DebugOverlayWindow.window == nil {
            let window = DebugOverlayWindow()
            window.isHidden = false
            DebugOverlayWindow.window = window
        }
    }

    public static func hide() {
        DebugOverlayWindow.window = nil
    }

    public static func toggle() {
        if DebugOverlayWindow.window == nil {
            DebugOverlayWindow.show()
        } else {
            DebugOverlayWindow.hide()
        }
    }

    // MARK: - lifecycle

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.overlayViewController.delegate = DebugOverlayWindow.delegate
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.rootViewController = self.overlayViewController
        self.windowLevel = UIWindowLevelStatusBar + 100.0
        self.backgroundColor = UIColor.clear
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - public methods

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return overlayViewController.shouldHandleTouch(at: point)
    }
}
