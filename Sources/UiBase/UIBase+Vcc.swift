//
//  UIViewControllerextension.swift
//  
//
//  Created by muze on 2022/09/29.
//

import UIKit
public extension UIViewController {
    func removeChild(_ tagToRemove: String) {
        let vcc = children.first(where: { $0.tagString == tagToRemove })
        if let vcc = vcc {
            vcc.willMove(toParent: nil)
            vcc.view.removeFromSuperview()
            vcc.removeFromParent()
        }
    }
    func findChild(_ tagToFind: String) -> Bool {
        children.first(where: { $0.tagString == tagToFind }) != nil
    }
}

private var tagAssociationKey: UInt8 = 0
public extension UIViewController {
    var tagString: String! {
        get {
            return objc_getAssociatedObject(self, &tagAssociationKey) as? String ?? "invalidStringKey1697"
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tagAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
