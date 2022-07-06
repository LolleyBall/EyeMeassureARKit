//
//  StoryboardInstantiable.swift
//  EyeMeassure
//
//  Created by Ruslan Lisovich on 08.04.2022.
//

import UIKit

protocol StoryboardInstantiable: NSObjectProtocol {
    associatedtype MyType
    static func instantiateViewController(storyboardId: String,
                                          _ bundle: Bundle?) -> MyType
}

extension StoryboardInstantiable where Self: UIViewController {
    static func instantiateViewController(storyboardId: String,
                                          _ bundle: Bundle? = nil) -> Self {
        let fileName = storyboardId
        let storyboard = UIStoryboard(name: fileName, bundle: bundle)
        // swiftlint:disable force_cast
        return storyboard.instantiateInitialViewController() as! Self
    }
}
