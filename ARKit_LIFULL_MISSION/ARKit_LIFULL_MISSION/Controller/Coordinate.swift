//
//  Coordinate.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/02/03.
//

import Foundation
import SceneKit

// MARK: - Definitions

typealias Coordinate = simd_float2

// MARK: - Coordinate Methods

extension Coordinate {

    func convertPercentToPoint(in drawSize: CGSize) -> CGPoint {
        CGPoint(x: CGFloat(self.x) / 100 * drawSize.width,
                y: CGFloat(self.y) / 100 * drawSize.height)
    }

    // e.g. 0.01m, 0.22m, 12.24m, 123.45m
    static func createDistanceLabelTitle(from startPoint: Coordinate, to endPoint: Coordinate) -> String {
        let distance = Self.calculateDistance(from: startPoint, to: endPoint)
        let roundedDistance = (distance * 100).rounded() / 100

        return String(format: "%.2fm", roundedDistance)
    }

    static func calculateDistance(from startPoint: Coordinate, to endPoint: Coordinate) -> Float {
        let distance = sqrt(pow(startPoint.x - endPoint.x, 2) +
                                pow(startPoint.y - endPoint.y, 2))

        return distance
    }
}
