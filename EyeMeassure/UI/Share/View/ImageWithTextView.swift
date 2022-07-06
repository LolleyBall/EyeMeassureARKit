//
//  ImageWithTextView.swift
//  EyeMeassure
//
//  Created by Gleb Sysoev on 07.04.2022.
//

import UIKit

final class ImageWithTextView: UIControl {

    struct Model {
        let image: UIImage?
        let title: String
    }

    // MARK: - UI

    private lazy var imageView: UIImageView = {
        UIImageView()
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Private

    private func commonInit() {
        setUpUI()
    }

    private func setUpUI() {
        addSubview(imageView)
        addSubview(textLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: textLabel.topAnchor, constant: -10),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            textLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - Public

    func setup(with model: Model) {
        imageView.image = model.image
        textLabel.text = model.title
    }
}
