//
//  RTButton.swift
//  EyeMeassure
//
//  Created by Ruslan Lisovich on 08.04.2022.
//

import UIKit

final class RTButton: UIButton {

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        self.addSubview(indicator)
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                     indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)])
        indicator.isHidden = true
        return indicator
    }()

    var isLoading: Bool {
        get {
            return !activityIndicator.isHidden
        }
        set {
            activityIndicator.isHidden = !newValue
            if newValue {
                self.setTitle("", for: UIControl.State.disabled)
                activityIndicator.startAnimating()
                self.isEnabled = false
            } else {
                self.isEnabled = true
                self.setTitle(self.title(for: .normal), for: UIControl.State.disabled)
                activityIndicator.stopAnimating()
            }
        }
    }

    override var isEnabled: Bool {
        get { return super.isEnabled }
        set {
            if newValue {
                self.alpha = 1
            } else {
                self.alpha = 0.7
            }
            super.isEnabled = newValue
        }
    }
}
