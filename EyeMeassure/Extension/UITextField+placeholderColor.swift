//
//  UITextField+placeholderColor.swift
//  EyeMeassure
//
//  Created by Timur Guliamov on 09.04.2022.
//

import UIKit

extension UITextField {
   @IBInspectable var placeHolderColor: UIColor? {
        get { self.placeHolderColor }
        set {
            guard let newColor = newValue else { return }
            attributedPlaceholder = NSAttributedString(
                string: self.placeholder ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: newColor]
            )
        }
    }
}
