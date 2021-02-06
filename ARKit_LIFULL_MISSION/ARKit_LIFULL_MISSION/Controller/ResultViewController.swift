//
//  ResultViewController.swift
//  ARKit_LIFULL_MISSION
//
//  Created by ForAppleStoreAccount on 2021/02/06.
//

import UIKit

protocol ResultViewControllerDelegate: AnyObject {
    func backToMappingView()
}

class ResultViewController: UIViewController {

    // MARK: - Properties

    private var dotCoordinates = [Coordinate]()
    weak var delegate: ResultViewControllerDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        label.text = "計測が完了しました！"
        label.textAlignment = .center
        label.setDimensions(height: 40)
        return label
    }()

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
        button.setDimensions(height: 40)
        button.addTarget(self, action: #selector(backToMappingButtonTapped), for: .touchUpInside)

        return button
    }()

    // MARK: - Lifecycle

    convenience init(withDotCoordinates dotCoordinates: [Coordinate]) {
        self.init(nibName: nil, bundle: nil)
        self.dotCoordinates = dotCoordinates
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.backToMappingView()
    }

    // MARK: - Selectors

    @objc
    func backToMappingButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Helpers

    private func configureUI() {
        view.backgroundColor = .lifullBrandColor

        let resultStack = UIStackView(arrangedSubviews: [titleLabel, imageView, backToMappingButton])
        resultStack.axis = .vertical
        resultStack.spacing = 12
        resultStack.distribution = .fillProportionally
        view.addSubview(resultStack)

        resultStack.centerY(inView: view)
        resultStack.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 12, paddingRight: 12)

        if let image = createImage(withDotCoordinates: dotCoordinates) {
            imageView.image = image
        }
    }

    private func createImage(withDotCoordinates dotCoordinates: [Coordinate]) -> UIImage? {
        let resultImageView = ResultImageView(dotCoordinates: dotCoordinates)
        resultImageView.frame.size = CGSize(width: 1024, height: 1024)
        guard let image = resultImageView.convertToImage() else {
            return nil
        }

        return image
    }

}
