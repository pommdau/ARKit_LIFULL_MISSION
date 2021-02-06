//
//  ResultImageView.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/02/03.
//

/* 描画処理
 1. ある辺が平行になるように全座標を回転させる
 2. 座標の値を0-100になるようにする（0-100%として扱うため）
 ・全座標の値が0以上になるように全座標に下駄を履かせる
 ・全座標の値が100以下になるように倍率をかける
 3. 指定されたCGSizeに上記の画像をUIBezierPathで描画する

 references
 [Working with Matrices](https://developer.apple.com/documentation/accelerate/working_with_matrices)

 [【Swift3】UIViewのdrawの中で線や文字や画像を描画する \- しめ鯖日記](https://llcc.hatenablog.com/entry/2017/05/04/001356)
 */

import UIKit
import SceneKit

class ResultImageView: UIView {

    // MARK: - Properties

    var dotCoordinates = [Coordinate]()  // 座標の実値(m) 座標間の距離の計算用
    private var dotPercentages = [Coordinate]()  // 座標（%）。描画範囲に対して何%の位置に描画するかを定義。

    // MARK: - Lifecycle

    init(dotCoordinates: [Coordinate]) {
        super.init(frame: .zero)
        backgroundColor = .systemGray

        self.dotCoordinates = dotCoordinates

        let rotatedCoordinates = CoordinateManager.rotate(withCoordinates: dotCoordinates)
        self.dotPercentages = CoordinateManager.convertCoordinatesToPercentages(withCoordinates: rotatedCoordinates)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    override func draw(_ rect: CGRect) {

        // ドットを結んで描画
        let path = createLines(to: dotPercentages, in: rect.size)
        UIColor.red.setStroke()
        path.lineWidth = 5

        // [Subtle Tile Patterns Vol8](https://www.pixeden.com/graphic-web-backgrounds/subtle-tile-patterns-vol8)
        if let floorImage = UIImage(named: "004-polished-wood") {
            UIColor(patternImage: floorImage).setFill()
        } else {
            UIColor.white.setFill()  // 通常は通らない
        }
        path.fill()
        path.stroke()

        for i in 0 ..< dotPercentages.count {
            let nextIndex = (i == dotPercentages.count - 1) ? 0 : i + 1
            let startPercentage = dotPercentages[i]
            let endPercentage   = dotPercentages[nextIndex]
            let labelTitle = Coordinate.createDistanceLabelTitle(from: dotCoordinates[i],
                                                                 to: dotCoordinates[nextIndex])

            // ラベルの背景の四角形を描画
            let labelBackgroundPath = createLabelBackgroundRect(title: labelTitle,
                                                                startPercentage: startPercentage,
                                                                endPercentage: endPercentage,
                                                                in: rect.size)
            UIColor.white.setFill()
            labelBackgroundPath.fill()

            // ラベルの描画
            let labelPoint = calculateLabelPoint(title: labelTitle,
                                                 startPercentage: startPercentage,
                                                 endPercentage: endPercentage,
                                                 in: rect.size)

            labelTitle.draw(at: labelPoint, withAttributes: [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
            ])
        }
    }
}
