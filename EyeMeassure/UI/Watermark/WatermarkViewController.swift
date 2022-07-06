//
//  WatermarkViewController.swift
//  EyeMeassure
//
//  Created by Timur Guliamov on 07.04.2022.
//

import UIKit

// MARK: watermark stuff: BEGIN

final class WatermarkViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        let stackView = Self.makeStackView()
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        Array(repeating: ["Demo", "Gleb Sysoev"], count: 4).flatMap { $0 }
            .map(Self.makeLabel)
            .forEach { stackView.addArrangedSubview($0) }
    }
}

extension WatermarkViewController {
    private static func makeStackView() -> UIStackView {
        let result = UIStackView()
        result.axis = .vertical
        result.alignment = .center
        result.distribution = .fillEqually
        return result
    }

    private static func makeLabel(text: String) -> UILabel {
        let result = UILabel()
        result.text = text
        result.textColor = .white
        result.textAlignment = .center
        result.font = .boldSystemFont(ofSize: 37.0)
        result.alpha = 0.3
        result.lineBreakMode = .byCharWrapping
        return result
    }
}

// MARK: watermark stuff: END
