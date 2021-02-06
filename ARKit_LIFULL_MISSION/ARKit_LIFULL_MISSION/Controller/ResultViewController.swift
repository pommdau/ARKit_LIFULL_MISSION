//
//  ResultViewController.swift
//  ARKit_LIFULL_MISSION
//
//  Created by ForAppleStoreAccount on 2021/02/06.
//

import UIKit

class ResultViewController: UIViewController {

    // MARK: - Properties

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 5
        imageView.setSizeAspect(widthRatio: 1.0, heightRatio: 1.0)

        return imageView
    }()

    private lazy var backToMappingButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitleColor(.lifullBrandColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitle("新しく計測する", for: .normal)
        button.layer.cornerRadius = 5
        button.setHeight(height: 40)
        button.addTarget(self, action: #selector(backToMappingButtonTapped), for: .touchUpInside)

        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    // MARK: - Selectors

    @objc func backToMappingButtonTapped() {
        print("backToMappingButtonTapped: ")
    }

    // MARK: - Helpers

    func configureUI() {
        view.backgroundColor = .lifullBrandColor

        let resultStack = UIStackView(arrangedSubviews: [imageView, backToMappingButton])
        resultStack.axis = .vertical
        resultStack.spacing = 8
        resultStack.distribution = .fillProportionally
        view.addSubview(resultStack)

        resultStack.centerY(inView: view)
        resultStack.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 12, paddingRight: 12)

        let resultImageView = ResultImageView(dotCoordinates: [
            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10))
        ])
        resultImageView.frame.size = CGSize(width: 1024, height: 1024)

        guard let image = resultImageView.convertToImage() else {
            return
        }
        imageView.image = image
    }

}
