//
//  Validator.swift
//  EyeMeassure
//
//  Created by Timur Guliamov on 09.04.2022.
//

import Foundation
import PhoneNumberKit

protocol PhoneValidator {
    func validatePhone(_ phoneString: String) -> Bool
}

protocol EmailValidator {
    func validateEmail(_ emailString: String) -> Bool
}

protocol PasswordValidator {
    func validatePassword(_ passwordString: String) -> Bool
}

protocol NameValidator {
    func validateName(_ nameString: String) -> Bool
}

protocol AdressValidator {
    func validateAdress(_ adressString: String) -> Bool
}

struct Validator {
    private let phoneNumberKit = PhoneNumberKit()
}

// MARK: - PhoneValidator

extension Validator: PhoneValidator {
    func validatePhone(_ phoneString: String) -> Bool {
        phoneNumberKit.isValidPhoneNumber(phoneString)
    }
}

// MARK: - EmailValidator

extension Validator: EmailValidator {
    func validateEmail(_ emailString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailString)
    }
}

// MARK: - PasswordValidator

extension Validator: PasswordValidator {
    func validatePassword(_ emailString: String) -> Bool {
        emailString.count > 6
    }
}

// MARK: - AdressValidator

extension Validator: AdressValidator {
    func validateAdress(_ adressString: String) -> Bool {
        !adressString.isEmpty
    }
}

// MARK: - NameValidator

extension Validator: NameValidator {
    func validateName(_ nameString: String) -> Bool {
        !nameString.isEmpty
    }
}
