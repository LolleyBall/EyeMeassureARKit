//
//  ShareViewController.swift
//  EyeMeassure
//
//  Created by Gleb Sysoev on 07.04.2022.
//

import UIKit

final class ShareViewController: UIViewController {

    // MARK: - UI

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var shareOptionsStackView: UIStackView!
    @IBOutlet private weak var backButton: UIButton!

    var service: ShareServiceProtocol = ShareService()
    var router: ShareRouterProtocol?
    var photo: UIImage?

    // MARK: - Lyfecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        photoImageView.image = photo

        service.options.enumerated().forEach { index, option in
            let optionView = shareOptionsStackView.arrangedSubviews
                .first(where: { $0.tag == index + 1 }) as? ImageWithTextView

            switch option {
            case .system:
                optionView?.setup(with: ImageWithTextView.Model(image: UIImage(imageLiteralResourceName: "share"),
                                                                title: "Share"))
            }
            optionView?.addTarget(self, action: #selector(didTapShareOption(sender:)), for: .touchUpInside)
            backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        }
    }

    @objc private func didTapShareOption(sender: UIView) {
        guard let option = service.options.enumerated().first(where: { $0.offset + 1 == sender.tag })?.element,
              let photo = photo else {
                  return
              }
        switch option {
        case .system:
            let activityController = UIActivityViewController(
                activityItems: [photo],
                applicationActivities: nil)
            self.present(activityController, animated: true)
        }
    }

    @objc private func didTapBack(_ sender: UIButton) {
        router?.close()
    }
}
