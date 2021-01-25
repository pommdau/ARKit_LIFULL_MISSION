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
    
    init(from: SCNVector3, to: SCNVector3) {
        super.init()
        
        // [How to draw a line between two points in SceneKit?](https://stackoverflow.com/questions/58470229/how-to-draw-a-line-between-two-points-in-scenekit)
        let x1 = from.x
        let x2 = to.x
        
        let y1 = from.y
        let y2 = to.y
        
        let z1 = from.z
        let z2 = to.z
        
        let distance =  sqrtf( (x2-x1) * (x2-x1) +
                                (y2-y1) * (y2-y1) +
                                (z2-z1) * (z2-z1) )
        
        let cylinder = SCNCylinder(radius: 0.001,
                                   height: CGFloat(distance))
        cylinder.firstMaterial?.diffuse.contents = UIColor.lifullSecondaryBrandColor
        geometry = cylinder
        position = SCNVector3(x: (x1 + x2) / 2,
                              y: (y1 + y2) / 2,
                              z: (z1 + z2) / 2)
        
        eulerAngles = SCNVector3(Float.pi / 2,
                                 acos((to.z-from.z)/distance),
                                 atan2((to.y-from.y),(to.x-from.x)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    
}

