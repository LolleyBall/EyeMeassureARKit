//
//  Formatter.swift
//  EyeMeassure
//
//  Created by Timur Guliamov on 09.04.2022.
//

import Foundation
import PhoneNumberKit

protocol PhoneFormatter {
    func formatPhone(_ phoneString: String?) -> String?
}

struct Formatter {
    private let phoneNumberKit = PhoneNumberKit()
}

// MARK: - PhoneFormatter

extension Formatter: PhoneFormatter {
    func formatPhone(_ phoneString: String?) -> String? {
        guard let phoneString = phoneString,
              let phoneNumber = try? phoneNumberKit.parse(phoneString)
        else { return phoneString }

        return phoneNumberKit.format(phoneNumber, toType: .international)
    }
}
