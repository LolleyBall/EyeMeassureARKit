//
//  UIAlertController+Settings.swift
//  EyeMeassure
//
//  Created by Роман Горбенко on 08.04.2022.
//

import Foundation
import UIKit

extension UIAlertController {
    static func toSettingsAlert(title: String, message: String, completion: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.dismiss(animated: true, completion: completion)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in

            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)

        return alertController
    }
}
