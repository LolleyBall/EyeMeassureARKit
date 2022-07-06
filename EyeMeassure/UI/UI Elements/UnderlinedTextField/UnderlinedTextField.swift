//
//  UnderlinedLabel.swift
//  EyeMeassure
//
//  Created by Ruslan Lisovich on 08.04.2022.
//

import UIKit

final class UnderlinedTextField: UIView, NibLoadable {
    @IBOutlet weak var textField: UITextField!

    @IBInspectable var shouldHideText: Bool = false {
        didSet {
            textField.isSecureTextEntry = shouldHideText
        }
    }

    @IBInspectable var placeholder: String = "" {
        didSet {
            self.textField.placeholder = placeholder
        }
    }

    var text: String? {
        return textField.text
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
}
