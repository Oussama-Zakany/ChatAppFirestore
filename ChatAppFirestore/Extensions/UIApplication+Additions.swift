//
//  UIApplication+Additions.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import UIKit

extension UIApplication {
    
    public static func setRootView(_ viewController: UIViewController, options: UIView.AnimationOptions = .transitionCrossDissolve, animated: Bool = true, duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        
        guard animated else {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            return
        }
        
        UIView.transition(with: UIApplication.shared.keyWindow!, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            UIApplication.shared.keyWindow?.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }) { _ in
            completion?()
        }
    }
}
