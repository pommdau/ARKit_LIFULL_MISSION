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

    // MARK: - Properties

    // MARK: - Lifecycle

    init(hitResult: ARHitTestResult, color: UIColor = .lifullSecondaryBrandColor) {

        super.init()

        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = color
        dotGeometry.materials = [material]
        geometry = dotGeometry

        position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selectors

    // MARK: - Helpers

}
