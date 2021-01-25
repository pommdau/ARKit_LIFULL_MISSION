//
//  DistanceNode.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/01/26.
//

import UIKit
import SceneKit
import ARKit

class DistanceLabelNode: SCNNode {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    init(text: String, position: SCNVector3) {
        
        super.init()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//        textGeometry.materials = [material]
//        let textNode = SCNNode(geometry: textGeometry)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue  // Materialが1つしかない場合はこう書ける？
        geometry = textGeometry
        self.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        scale = SCNVector3(0.01, 0.01, 0.01)  // 1%に縮小
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    
}
