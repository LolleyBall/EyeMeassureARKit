//
//  AppDelegate.swift
//  EyeMeassure
//
//  Created by Gleb Sysoev on 06.04.2022.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // MARK: watermark stuff: BEGIN
    private var watermarkWindow: UIWindow?
    // MARK: watermark stuff: END

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        if let navVC = UIStoryboard(name: "Auth", bundle: nil)
            .instantiateInitialViewController() as? UINavigationController,
           let mainVC = navVC.viewControllers.first as? AuthViewController {
            mainVC.router = AuthRouter(controller: mainVC)
            window?.rootViewController = navVC
        }

        FirebaseApp.configure()

        // MARK: watermark stuff: BEGIN
        setupWatermark()
        // MARK: watermark stuff: END

        return true
    }

    // MARK: watermark stuff: BEGIN
    private func setupWatermark() {
        let watermarksWindow = UIWindow()
        self.watermarkWindow = watermarksWindow
        watermarksWindow.rootViewController = WatermarkViewController()
        watermarksWindow.windowLevel = .alert
        watermarksWindow.backgroundColor = .clear
        watermarksWindow.isUserInteractionEnabled = false
        watermarksWindow.makeKeyAndVisible()
    }
    // MARK: watermark stuff: END
}
