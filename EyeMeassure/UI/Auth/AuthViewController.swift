//
//  AuthViewController.swift
//  EyeMeassure
//
//  Created by Ruslan Lisovich on 08.04.2022.
//

import UIKit

final class AuthViewController: UIViewController, StoryboardInstantiable {
    class var storyboardIdentifier: String { "Auth" }

    private enum ShownPage {
        case login
        case signUp
    }

    private var shownPage: ShownPage = .login { didSet { didUpdateShownPage() } }
    private let formatter = Formatter()
    private let validator = Validator()

    // Login
    @IBOutlet private weak var emailLoginTextField: UnderlinedTextField!
    @IBOutlet private weak var passwordLoginTextField: UnderlinedTextField!
    @IBOutlet private weak var loginRTButton: RTButton!
    @IBOutlet private weak var loginErrorLabel: UILabel!
    @IBOutlet private weak var loginErrorLabelHeightConstraint: NSLayoutConstraint!

    // Sign-Up
    @IBOutlet private weak var nameSignUpTextView: UnderlinedTextField!
    @IBOutlet private weak var emailSignUpTextField: UnderlinedTextField!
    @IBOutlet private weak var adressSignUpTextField: UnderlinedTextField!
    @IBOutlet private weak var phoneSignUpTextField: UnderlinedTextField!
    @IBOutlet private weak var passwordSignUpTextField: UnderlinedTextField!
    @IBOutlet private weak var confirmPasswordSignUpTextField: UnderlinedTextField!
    @IBOutlet private weak var signUpRTButton: RTButton!
    @IBOutlet private weak var signUpErrorLabel: UILabel!
    @IBOutlet private weak var signUpErrorLabelHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var verticalScrollView: UIScrollView!

    var router: AuthViewControllerProtocol!

    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    let authorized = UserDefaults.standard.bool(forKey: "authorized")

    override func viewDidLoad() {
        super.viewDidLoad()
        if launchedBefore && authorized {
            authCheck()
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        setupTextFields()
        setupKeyboard()
        registerForKeyboardNotifications()
    }

    deinit {
        removeKeyboardNotifications()
    }

    // MARK: - IBAction

    @IBAction func createAccountButtonClicked(_ sender: Any) {
        shownPage = .signUp
    }

    @IBAction func alreadyMemberClicked(_ sender: Any) {
        shownPage = .login
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        loginRTButton.isEnabled = false

        guard let emailText = emailLoginTextField.text,
              validator.validateEmail(emailText) else {
                  updateLoginErrorLabel(text: R.string.localizable.authBadEmail())
                  loginRTButton.isEnabled = true
                  return
              }

        guard let passwordText = passwordLoginTextField.text,
              validator.validatePassword(passwordText) else {
                  updateLoginErrorLabel(text: R.string.localizable.authBadPassword())
                  loginRTButton.isEnabled = true
                  return
              }

        updateLoginErrorLabel(text: nil)

        login(email: emailText, password: passwordText)
    }

    @IBAction func signupButtonClicked(_ sender: Any) {
        signUpRTButton.isEnabled = false

        guard let nameText = nameSignUpTextView.text,
              validator.validateName(nameText) else {
                  updateSignUpErrorLabel(text: R.string.localizable.authBadName())
                  signUpRTButton.isEnabled = true
                  return
              }

        guard let adressText = adressSignUpTextField.text,
              validator.validateAdress(adressText) else {
                  updateSignUpErrorLabel(text: R.string.localizable.authBadAdress())
                  signUpRTButton.isEnabled = true
                  return
              }

        guard let emailText = emailSignUpTextField.text,
              validator.validateEmail(emailText) else {
                  updateSignUpErrorLabel(text: R.string.localizable.authBadEmail())
                  signUpRTButton.isEnabled = true
                  return
              }

        let phoneText = phoneSignUpTextField.text
        if let phoneText = phoneText,
           !validator.validatePhone(phoneText) && !phoneText.isEmpty {
            updateSignUpErrorLabel(text: R.string.localizable.authBadPhone())
            signUpRTButton.isEnabled = true
            return
        }

        guard let passwordText = passwordSignUpTextField.text,
              validator.validatePassword(passwordText) else {
                  updateSignUpErrorLabel(text: R.string.localizable.authBadPassword())
                  signUpRTButton.isEnabled = true
                  return
              }

        guard let confirmPasswordText = confirmPasswordSignUpTextField.text,
              confirmPasswordText == passwordText else {
                  updateSignUpErrorLabel(text: R.string.localizable.authBadConfirmPassword())
                  signUpRTButton.isEnabled = true
                  return
              }

        updateSignUpErrorLabel(text: nil)

        let user = User(name: nameText, adress: adressText, phone: phoneText)

        signup(email: emailText, password: passwordText, user: user)
    }

    private func login(email: String, password: String) {
        NetworkManager.shared.loadUser(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let user):
                self?.router.goToMain(user: user)
                UserDefaults.standard.set(true, forKey: "authorized")
                self?.loginRTButton.isEnabled = true
            case .failure(let error):
                self?.loginRTButton.isEnabled = true
                switch error {
                case NetworkError.userNotFound:
                    self?.updateLoginErrorLabel(text: "2")
                case NetworkError.invalidEmail:
                    self?.updateLoginErrorLabel(text: "3")
                case NetworkError.wrongPassword:
                    self?.updateLoginErrorLabel(text: "4")
                case NetworkError.networkError:
                    self?.updateLoginErrorLabel(text: "6")
                default:
                    self?.updateLoginErrorLabel(text: "7")
                }
            }
        }
    }

    private func signup(email: String, password: String, user: User) {
        NetworkManager.shared.createUser(email: email,
                                         password: password,
                                         user: user) { [weak self] result in
            switch result {
            case .success:
                self?.router.goToMain(user: user)
                UserDefaults.standard.set(true, forKey: "authorized")
                self?.signUpRTButton.isEnabled = true
            case .failure(let error):
                self?.signUpRTButton.isEnabled = true
                switch error {
                case NetworkError.networkError:
                    self?.updateSignUpErrorLabel(text: "")
                case NetworkError.weakPassword:
                    self?.updateSignUpErrorLabel(text: "")
                case NetworkError.invalidEmail:
                    self?.updateSignUpErrorLabel(text: "3")
                case NetworkError.emailAlreadyInUse:
                    self?.updateSignUpErrorLabel(text: "User already exists")
                default:
                    self?.updateLoginErrorLabel(text: "")
                }
            }
        }
    }

    private func authCheck() {
        NetworkManager.shared.authCheck { [weak self] result in
            switch result {
            case .success(let user):
                self?.router.goToMain(user: user)
            case .failure(let error):
                switch error {
                case NetworkError.userNotFound:
                    self?.updateLoginErrorLabel(text: "2")
                case NetworkError.networkError:
                    self?.updateLoginErrorLabel(text: "6")
                default:
                    self?.updateLoginErrorLabel(text: "7")
                }
            }
        }
    }

    // MARK: - Private

    private func setupTextFields() {
        emailLoginTextField.textField.delegate = self
        emailLoginTextField.textField.textContentType = .emailAddress
        emailLoginTextField.textField.keyboardType = .emailAddress

        passwordLoginTextField.textField.delegate = self
        passwordLoginTextField.textField.textContentType = .password

        nameSignUpTextView.textField.delegate = self
        nameSignUpTextView.textField.textContentType = .name

        emailSignUpTextField.textField.delegate = self
        emailSignUpTextField.textField.textContentType = .emailAddress
        emailSignUpTextField.textField.keyboardType = .emailAddress

        adressSignUpTextField.textField.delegate = self
        adressSignUpTextField.textField.textContentType = .fullStreetAddress

        phoneSignUpTextField.textField.delegate = self
        phoneSignUpTextField.textField.keyboardType = .phonePad
        phoneSignUpTextField.textField.textContentType = .telephoneNumber

        passwordSignUpTextField.textField.delegate = self
        passwordSignUpTextField.textField.textContentType = .newPassword

        confirmPasswordSignUpTextField.textField.delegate = self
        confirmPasswordSignUpTextField.textField.textContentType = .newPassword
    }

    private func setupKeyboard() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        )
    }

    private func didUpdateShownPage() {
        let contentOffset: CGPoint
        switch shownPage {
        case .login: contentOffset = .zero
        case .signUp: contentOffset = CGPoint(x: scrollView.frame.width, y: 0)
        }

        scrollView.setContentOffset(contentOffset, animated: true)
    }

    @objc private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(false)
    }

    // MARK: - Hide Keyboard

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(kbWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(kbWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func kbWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let kbFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        verticalScrollView.contentInset.bottom = kbFrameSize.height
    }

    @objc private func kbWillHide() {
        verticalScrollView.contentInset.bottom = .zero
    }

    private func updateLoginErrorLabel(text: String?) {
        loginErrorLabel.text = text
        loginErrorLabelHeightConstraint.constant = text != nil ? 20 : 0
        view.layoutIfNeeded()
    }

    private func updateSignUpErrorLabel(text: String?) {
        signUpErrorLabel.text = text
        signUpErrorLabelHeightConstraint.constant = text != nil ? 20 : 0
        view.layoutIfNeeded()
    }
}

extension AuthViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text,
              let textRange = Range(range, in: text)
        else { return true }

        let updatedText = text.replacingCharacters(in: textRange, with: string)

        switch textField {
        case phoneSignUpTextField.textField:
            textField.text = formatter.formatPhone(updatedText)

        case emailLoginTextField.textField,
            passwordLoginTextField.textField,
            nameSignUpTextView.textField,
            emailSignUpTextField.textField,
            adressSignUpTextField.textField,
            passwordSignUpTextField.textField,
            confirmPasswordSignUpTextField.textField:
            textField.text = updatedText

        default:
            break
        }

        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailLoginTextField.textField: passwordLoginTextField.textField.becomeFirstResponder()
        case passwordLoginTextField.textField: view.endEditing(false)

        case nameSignUpTextView.textField: emailSignUpTextField.textField.becomeFirstResponder()
        case emailSignUpTextField.textField: adressSignUpTextField.textField.becomeFirstResponder()
        case adressSignUpTextField.textField: phoneSignUpTextField.textField.becomeFirstResponder()
        case phoneSignUpTextField.textField: passwordSignUpTextField.textField.becomeFirstResponder()
        case passwordSignUpTextField.textField: confirmPasswordSignUpTextField.textField.becomeFirstResponder()
        case confirmPasswordSignUpTextField.textField: view.endEditing(false)

        default: break
        }

        return true
    }
}
