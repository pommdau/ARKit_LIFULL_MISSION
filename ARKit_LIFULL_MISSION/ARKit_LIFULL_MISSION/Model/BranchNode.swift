//
//  BranchNode.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/01/26.
//

import UIKit
import SceneKit
import ARKit

class BranchNode: SCNNode {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    init(startingNode: DotNode, endingNode: DotNode) {
        super.init()
        
        let length = DotNode.calculateDistance(firstDotNode: startingNode,
                                               secondDotNode: endingNode)
        let branchGeometry = SCNCylinder(radius: 0.0025,
                                         height: CGFloat(length))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemGreen
        branchGeometry.materials = [material]
        
        transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0.5, 0)
        geometry = branchGeometry
        
        position = SCNVector3(
            x: startingNode.position.x,
            y: startingNode.position.y,
            z: startingNode.position.z - length / 2
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    
}

