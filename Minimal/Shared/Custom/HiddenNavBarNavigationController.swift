//
//  NavigationController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class InteractivePopRecognizer: NSObject {
    fileprivate weak var navigationController: UINavigationController?
    
    init(controller: UINavigationController) {
        navigationController = controller
        super.init()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

extension InteractivePopRecognizer: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    // This is necessary because without it, subviews of your top controller can cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class HiddenNavBarNavigationController: UINavigationController {
    private var popRecognizer: InteractivePopRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopRecognizer()
    }
    
    private func setupPopRecognizer() {
        popRecognizer = InteractivePopRecognizer(controller: self)
    }
}

