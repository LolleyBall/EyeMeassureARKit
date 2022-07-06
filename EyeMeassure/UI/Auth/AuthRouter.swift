//
//  AuthRouter.swift
//  EyeMeassure
//
//  Created by Vadim Aleshin on 09.04.2022.
//

import UIKit

protocol AuthViewControllerProtocol {
    func goToMain(user: User)
}

struct AuthRouter {
    weak var controller: AuthViewController?
}

// MARK: - MainScreenRouterProtocol

extension AuthRouter: AuthViewControllerProtocol {
    func goToMain(user: User) {
        guard let mainVC = R.storyboard.main.mainScreen() else { return }
        mainVC.router = MainScreenRouter(controller: mainVC)
        mainVC.user = user
        controller?.navigationController?.pushViewController(mainVC, animated: true)
    }
}
