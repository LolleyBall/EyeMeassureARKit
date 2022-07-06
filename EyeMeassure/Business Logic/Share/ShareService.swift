//
//  ShareService.swift
//  EyeMeassure
//
//  Created by Gleb Sysoev on 07.04.2022.
//

import Foundation

protocol ShareServiceProtocol {
    var options: [ShareOption] { get }
}

final class ShareService: ShareServiceProtocol {
    var options = [ShareOption.system]
}
