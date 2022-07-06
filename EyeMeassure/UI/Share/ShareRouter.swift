//
//  ShareRouter.swift
//  EyeMeassure
//
//  Created by Vadim Aleshin on 09.04.2022.
//

protocol ShareRouterProtocol {
    func close()
}

struct ShareRouter {
    weak var controller: ShareViewController?
}

// MARK: - QuestionRouterProtocol

extension ShareRouter: ShareRouterProtocol {
    func close() {
        controller?.navigationController?.popViewController(animated: true)
    }
}
