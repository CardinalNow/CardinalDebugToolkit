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

public class DebugOverlayViewController: UIViewController {
    internal weak var delegate: DebugOverlayDelegate?
    private var toolbarFrameBeforeDragging = CGRect(x: 0, y: 0, width: 0, height: 0)
    private let toolbar = UIView(frame: CGRect(x: 0, y: 20, width: 50, height: 50))

    // MARK: - lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleToolbarPanGesture(_:)))
        toolbar.addGestureRecognizer(gestureRecognizer)
        toolbar.backgroundColor = DebugOverlayWindow.toolbarBackgroundColor ?? UIColor.black
        toolbar.layer.cornerRadius = 6.0

        let button = UIButton(type: .system)
        button.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        button.setTitle("Debug", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        button.tintColor = DebugOverlayWindow.toolbarTintColor ?? UIColor.red
        button.addTarget(self, action: #selector(showActions), for: .primaryActionTriggered)

        toolbar.addSubview(button)

        view.addSubview(toolbar)
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

    @objc
    private func handleToolbarPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        func updateToolbarPosition(with gestureRecognizer: UIPanGestureRecognizer) {
            let localPoint = gestureRecognizer.translation(in: self.view)
            var newFrame = self.toolbarFrameBeforeDragging
            newFrame.origin.x += localPoint.x
            newFrame.origin.y += localPoint.y

            if newFrame.minX < 0.0 {
                newFrame.origin.x = 0.0
            } else if newFrame.maxX > self.view.bounds.width {
                newFrame.origin.x = self.view.bounds.width - newFrame.size.width
            }
            if newFrame.minY < 0.0 {
                newFrame.origin.y = 0.0
            } else if newFrame.maxY > self.view.bounds.height {
                newFrame.origin.y = self.view.bounds.height - newFrame.size.height
            }

            self.toolbar.frame = newFrame
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
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let actions = delegate?.actions() {
            for action in actions {
                vc.addAction(UIAlertAction(title: action.title, style: .default, handler: { (_) in
                    let vc = self.delegate?.didSelectAction(withId: action.id)
                    if let vc = vc {
                        self.show(vc, sender: self)
                    }
                }))
            }
        }
        if DebugOverlayWindow.showHideAction {
            vc.addAction(UIAlertAction(title: "Hide Overlay", style: .destructive, handler: { (_) in
                DebugOverlayWindow.hide()
            }))
        }
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        show(vc, sender: self)
    }
}
