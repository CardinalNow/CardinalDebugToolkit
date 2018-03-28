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
import UIKit

public class DebugOverlayViewController: UIViewController {
    internal weak var debugOverlay: DebugOverlay?
    private var toolbarFrameBeforeDragging = CGRect(x: 0, y: 0, width: 0, height: 0)
    private let toolbar = UIView(frame: CGRect(x: 0, y: 20, width: 50, height: 50))

    // MARK: - lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleToolbarPanGesture(_:)))
        toolbar.addGestureRecognizer(gestureRecognizer)
        toolbar.backgroundColor = debugOverlay?.toolbarBackgroundColor ?? UIColor.black
        toolbar.layer.cornerRadius = 6.0

        let button = UIButton(type: .system)
        button.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        button.setTitle("Debug", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        button.tintColor = debugOverlay?.toolbarTintColor ?? UIColor.red
        button.addTarget(self, action: #selector(showActions), for: .primaryActionTriggered)

        toolbar.addSubview(button)

        view.addSubview(toolbar)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        clampToolbarToSafeArea()
    }

    @available(iOS 11.0, *)
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        clampToolbarToSafeArea()
    }

    // MARK: - internal methods

    internal func shouldHandleTouch(at point: CGPoint) -> Bool {
        if presentedViewController != nil {
            return true
        }
        if toolbar.frame.contains(view.convert(point, from: nil)) {
            return true
        }

        return false
    }

    // MARK: - private methods

    private func clampToolbarToSafeArea() {
        let safeAreaInsets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeAreaInsets = view.safeAreaInsets
        } else {
            safeAreaInsets = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
        }

        let maxX = view.bounds.width - safeAreaInsets.right - toolbar.frame.width
        toolbar.frame.origin.x = max(
            min(maxX, toolbar.frame.origin.x),
            safeAreaInsets.left
        )
        let maxY = view.bounds.height - safeAreaInsets.bottom - toolbar.frame.height
        toolbar.frame.origin.y = max(
            min(maxY, toolbar.frame.origin.y),
            safeAreaInsets.top
        )
    }

    @objc
    private func handleToolbarPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        func updateToolbarPosition(with gestureRecognizer: UIPanGestureRecognizer) {
            let localPoint = gestureRecognizer.translation(in: self.view)
            var newFrame = self.toolbarFrameBeforeDragging
            newFrame.origin.x += localPoint.x
            newFrame.origin.y += localPoint.y
            self.toolbar.frame = newFrame

            clampToolbarToSafeArea()
        }

        switch gestureRecognizer.state {
        case .began:
            toolbarFrameBeforeDragging = toolbar.frame
            updateToolbarPosition(with: gestureRecognizer)
        case .changed, .ended:
            updateToolbarPosition(with: gestureRecognizer)
        default:
            break
        }
    }

    @objc
    private func showActions() {
        guard let debugOverlay = debugOverlay, let delegate = debugOverlay.delegate else { return }

        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for action in delegate.actionItemsForDebugOverlay(debugOverlay) {
            vc.addAction(UIAlertAction(title: action.title, style: .default, handler: { (_) in
                let vc = delegate.debugOverlay(debugOverlay, selectedActionWithId: action.id)
                if let vc = vc {
                    self.show(vc, sender: self)
                }
            }))
        }
        if delegate.debugOverlayShouldDisplayHideAction(debugOverlay) {
            vc.addAction(UIAlertAction(title: "Hide Overlay", style: .destructive, handler: { (_) in
                debugOverlay.hide()
            }))
        }
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        show(vc, sender: self)
    }
}
