//
//  MainViewController.swift
//  EyeMeassure
//
//  Created by Gleb Sysoev on 08.04.2022.
//

import UIKit
import AVFoundation

final class MainViewController: UIViewController {
    private let resultButton = UIButton(type: .system)
    private let helpButton = UIButton(type: .system)
    private let signoutButton = UIButton(type: .system)
    private let usernameLabel = UILabel()
    private let childViewController = R.storyboard.main.eyeSearch()

    var router: MainScreenRouterProtocol!
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupResultButton()
        setupHelpButton()
        setupSignoutButton()
        setupUsernameLabel()
        setupView()
        addTarget()

        childViewController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCameraAbaliable()
    }

    private func setupView() {
        checkARKitAvailable()
        view.addSubview(resultButton)
        view.addSubview(helpButton)
        view.addSubview(signoutButton)
        view.addSubview(usernameLabel)

        resultButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        signoutButton.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            resultButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultButton.heightAnchor.constraint(equalToConstant: LayoutConst.resultButtonHeight),
            resultButton.widthAnchor.constraint(equalToConstant: LayoutConst.resultButtonHeight * 2),
            resultButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: LayoutConst.resultButtonBottomInset),

            helpButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            helpButton.heightAnchor.constraint(equalToConstant: LayoutConst.helpButtonHeight),
            helpButton.widthAnchor.constraint(equalToConstant: LayoutConst.helpButtonHeight),
            helpButton.rightAnchor.constraint(equalTo: view.rightAnchor,
                                              constant: -LayoutConst.helpButtonInset),

            signoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            signoutButton.heightAnchor.constraint(equalToConstant: LayoutConst.helpButtonHeight),
            signoutButton.widthAnchor.constraint(equalToConstant: LayoutConst.helpButtonHeight),
            signoutButton.leftAnchor.constraint(equalTo: view.leftAnchor,
                                                constant: LayoutConst.helpButtonInset),

            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameLabel.centerYAnchor.constraint(equalTo: helpButton.centerYAnchor)
        ])
    }

    private func cameraReady() {
        DispatchQueue.main.async { [weak self] in
            self?.childViewController?.view.backgroundColor = .black
        }
    }

    @objc private func didResultButtonTapped(sender: UIButton) {
        let ARData = childViewController?.getARData()
        router.goToShare(data: ARData!)
    }

    @objc private func didHelpButtonTapped(sender: UIButton) {
    }

    @objc private func didSignoutButtonTapped(sender: UIButton) {
        let alert = UIAlertController(title: "Signout", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Continue",
                                      style: UIAlertAction.Style.destructive,
                                      handler: { _ in
            NetworkManager.shared.signout()
            UserDefaults.standard.set(false, forKey: "authorized")
            self.router.close()
        }))
    }

    private func addTarget() {
        resultButton.addTarget(self,
                               action: #selector(didResultButtonTapped),
                               for: .touchUpInside)
        helpButton.addTarget(self,
                             action: #selector(didHelpButtonTapped),
                             for: .touchUpInside)
        signoutButton.addTarget(self,
                                action: #selector(didSignoutButtonTapped),
                                for: .touchUpInside)
    }

    private func setupResultButton() {
        resultButton.setTitle("Result", for: .normal)
        resultButton.backgroundColor = .white
        resultButton.layer.cornerRadius = LayoutConst.resultButtonHeight / 2
        resultButton.layer.borderColor = UIColor.systemBlue.cgColor
        resultButton.layer.borderWidth = 3
        resultButton.addTarget(self, action: #selector(didResultButtonTapped(sender:)), for: .touchUpInside)
    }

    private func setupHelpButton() {
        helpButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        helpButton.backgroundColor = .clear
    }

    private func setupSignoutButton() {
        signoutButton.setImage(UIImage(systemName: "multiply"), for: .normal)
        signoutButton.backgroundColor = .clear
    }

    private func setupUsernameLabel() {
        usernameLabel.text = user?.name
        usernameLabel.textColor = .white
        usernameLabel.font = UIFont.systemFont(ofSize: 20)
    }

    private func addChildViewController() {
        guard let childViewController = childViewController else { return }

        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            childViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            childViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Const

    struct LayoutConst {
        static let resultButtonBottomInset: CGFloat = -20
        static let resultButtonHeight: CGFloat = 50
        static let helpButtonHeight: CGFloat = 50
        static let helpButtonInset: CGFloat = 10
    }
}

extension MainViewController: EyeSearchViewControllerDelegate {
    func eyeSearchViewController(_ viewController: EyeSearchViewController,
                                 didUpdateDistance distanceBetweenEyes: Float) -> String? {
        return String(format: "%.1f", distanceBetweenEyes * 1000) + " mm"
    }
}

extension MainViewController {
    func checkCameraAbaliable() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .denied, .restricted:
            let dialog = UIAlertController.toSettingsAlert(
                title: R.string.localizable.unableCameraTitle(),
                message: R.string.localizable.unableCameraMessage()) { [weak self] in
                    switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
                    case .authorized:
                        self?.cameraReady()
                    case .denied, .notDetermined, .restricted:
                        break
                    @unknown default:
                        break
                    }
                }
            self.present(dialog, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] (grantd) in
                if grantd {
                    self?.cameraReady()
                }
            }
        case .authorized:
            cameraReady()
        @unknown default:
            break
        }
    }

    func checkARKitAvailable() {
        guard let childViewController = childViewController else { return }

        if childViewController.availableARKit() {
            addChildViewController()
        } else {
            let dialog = UIAlertController(title: "Error",
                                           message: "This device does not support ARKit",
                                           preferredStyle: .alert)
            self.present(dialog, animated: true, completion: nil)
        }
    }
}
