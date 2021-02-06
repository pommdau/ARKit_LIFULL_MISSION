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
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 5
        return iv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    // MARK: - Selectors

    // MARK: - Helpers

    func configureUI() {

        view.backgroundColor = .lifullBrandColor

        view.addSubview(imageView)
        imageView.setDimensions(width: 600, height: 600)
        imageView.center(inView: view)

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
