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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    
}

// Static Methods

extension DotNode {
    /// 2点のDotNode間の距離を計算する
    static func calculateDistance(firstDotNode: DotNode, secondDotNode: DotNode) -> Float {
        let distance = sqrt(
            pow(secondDotNode.position.x - firstDotNode.position.x, 2) +
            pow(secondDotNode.position.y - firstDotNode.position.y, 2) +
            pow(secondDotNode.position.z - firstDotNode.position.z, 2)
        )
        return distance
    }
}
