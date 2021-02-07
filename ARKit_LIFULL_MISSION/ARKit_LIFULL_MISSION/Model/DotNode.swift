//
//  DotNode.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/01/25.
//

import UIKit
import SceneKit
import ARKit

class DotNode: SCNNode {

    // MARK: - Lifecycle

    init(position: SCNVector3, color: UIColor = .lifullSecondaryBrandColor) {

        super.init()

        let dotGeometry = SCNSphere(radius: 0.010)
        let material = SCNMaterial()
        material.diffuse.contents = color
        dotGeometry.materials = [material]
        self.geometry = dotGeometry
        self.position = position
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    func convertToCoordinate() -> Coordinate {
        Coordinate(position.x, position.z)
    }
}
