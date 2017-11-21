//
//  DebugOverlay.swift
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 11/13/17.
//  Copyright © 2017 Cardinal Solutions. All rights reserved.
//

import Foundation

public struct DebugOverlayActionItem {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public protocol DebugOverlayDelegate: class {
    func actionItemsForDebugOveray(_ overlay: DebugOverlay) -> [DebugOverlayActionItem]
    func debugOverlay(_ overlay: DebugOverlay, selectedActionWithId id: String) -> UIViewController?
    func debugOverlayShouldDisplayHideAction(_ overlay: DebugOverlay) -> Bool
}

public class DebugOverlay {
    public weak var delegate: DebugOverlayDelegate?
    public var toolbarBackgroundColor: UIColor?
    public var toolbarTintColor: UIColor?
    public var overlayWindow: DebugOverlayWindow?

    public init() {
    }

    public func show() {
        if overlayWindow == nil {
            let window = DebugOverlayWindow()
            window.isHidden = false
            window.debugOverlay = self
            window.overlayViewController.debugOverlay = self
            overlayWindow = window
        }
    }

    public func hide() {
        overlayWindow = nil
    }

    public func toggle() {
        if overlayWindow == nil {
            show()
        } else {
            hide()
        }
    }
}
