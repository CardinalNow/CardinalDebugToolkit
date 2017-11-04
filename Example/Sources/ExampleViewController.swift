//
//  ExampleViewController.swift
//  CardinalDebugToolkitExample
//
//  Created by Robin Kunde on 7/19/17.
//  Copyright © 2017 Cardinal Solutions. All rights reserved.
//

import Foundation
import UIKit

class ExampleViewController: UIViewController {
    // MARK: - lifecycle

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nvc = navigationController, nvc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelf))
        }
    }

    // MARK: - private methods

    @objc
    private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}
