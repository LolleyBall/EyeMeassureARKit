//
//  MainScreenRouter.swift
//  EyeMeassure
//
//  Created by Vadim Aleshin on 09.04.2022.
//

import UIKit

protocol MainScreenRouterProtocol {
    func goToShare(data: EyeSearchViewController.ARData)
    func close()
}

struct MainScreenRouter {
    weak var controller: MainViewController?
}

// MARK: - MainScreenRouterProtocol
extension MainScreenRouter: MainScreenRouterProtocol {
    func goToShare(data: EyeSearchViewController.ARData) {
        guard let shareVC = R.storyboard.share.shareView() else { return }
        shareVC.router = ShareRouter(controller: shareVC)
        shareVC.photo = data.image
        controller?.navigationController?.pushViewController(shareVC, animated: true)
    }

    func close() {
        controller?.navigationController?.popViewController(animated: true)
    }
}
