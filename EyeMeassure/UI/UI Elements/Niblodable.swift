//
//  Niblodable.swift
//  EyeMeassure
//
//  Created by Ruslan Lisovich on 08.04.2022.
//

import UIKit

// https://stackoverflow.com/a/47295926/9451842

public protocol NibLoadable {
    static var nibName: String { get }
}

extension NibLoadable where Self: UIView {

    static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }

    static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }

    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0),
                view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0),
                view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0)
                ])
    }
}
