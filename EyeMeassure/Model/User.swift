//
//  User.swift
//  EyeMeassure
//
//  Created by Gleb Sysoev on 08.04.2022.
//

import Foundation

struct User {
    let name: String
    let adress: String
    let phone: String?

    init(
        name: String,
        adress: String,
        phone: String?
    ) {
        self.name = name
        self.adress = adress
        self.phone = phone
    }

    init?(from dict: [String: Any]) {
        guard let username = dict["username"] as? String,
              let location = dict["adress"] as? String else {
            return nil
        }
        self.name = username
        self.adress = location
        self.phone = dict["phone"] as? String
    }
}
