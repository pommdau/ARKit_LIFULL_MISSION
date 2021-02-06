//
//  ResultImageView+Drawing.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/02/03.
//

import UIKit
import SceneKit

// MARK: - Drawing Methods
// [\[Swift 4\] UIBezierPathを使って遊んでみる\(その1\)](https://dev.classmethod.jp/articles/play-uibezierpath-1/)
extension ResultImageView {

    func createLines(to percentages: [Coordinate], in drawSize: CGSize) -> UIBezierPath {
        let path = UIBezierPath()

        percentages.forEach { percentage in
            let coordinate = percentage.convertPercentToPoint(in: drawSize)
            if percentages.first! == percentage {
                path.move(to: CGPoint(x: CGFloat(coordinate.x), y: CGFloat(coordinate.y)))
            } else {
                path.addLine(to: CGPoint(x: CGFloat(coordinate.x), y: CGFloat(coordinate.y)))
            }
        }
        path.close()

        return path
    }

    func createLabelBackgroundRect(title: String,
                                   sytetmFontSize: CGFloat = 14,
                                   startPercentage: Coordinate,
                                   endPercentage: Coordinate,
                                   in drawSize: CGSize) -> UIBezierPath {
        let startPoint = startPercentage.convertPercentToPoint(in: drawSize)
        let endPoint = endPercentage.convertPercentToPoint(in: drawSize)

        let labelSize = calculateLabelSize(title: title, sytetmFontSize: sytetmFontSize)
        let size = CGSize(width: labelSize.width + 10, height: labelSize.height + 3)  // 適当なマージンを加える
        let point = CGPoint(x: (startPoint.x + endPoint.x) / 2 - size.width / 2,
                            y: (startPoint.y + endPoint.y) / 2 - size.height / 2)
        let labelBackgroundRect = CGRect(origin: point, size: size)

        return UIBezierPath(roundedRect: labelBackgroundRect,
                            cornerRadius: 5)
    }

    func calculateLabelPoint(title: String,
                             sytetmFontSize: CGFloat = 14,
                             startPercentage: Coordinate,
                             endPercentage: Coordinate,
                             in drawSize: CGSize) -> CGPoint {

        let startPoint = startPercentage.convertPercentToPoint(in: drawSize)
        let endPoint = endPercentage.convertPercentToPoint(in: drawSize)

        let size = calculateLabelSize(title: title, sytetmFontSize: sytetmFontSize)
        let point = CGPoint(x: (startPoint.x + endPoint.x) / 2 - size.width / 2,
                            y: (startPoint.y + endPoint.y) / 2 - size.height / 2)

        return point
    }

    private func calculateLabelSize(title: String, sytetmFontSize: CGFloat = 14) -> CGSize {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()

        return label.frame.size
    }
}
