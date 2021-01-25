//
//  PlaneNode.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/01/25.
//

import UIKit
import SceneKit
import ARKit

class PlaneNode: SCNNode {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        let planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x),
                             height: CGFloat(anchor.extent.z))
        planeGeometry.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
        geometry = planeGeometry
        
        transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    
    func update(anchor: ARPlaneAnchor) {
        let planeGeometry = geometry as! SCNPlane
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    }
    
}
