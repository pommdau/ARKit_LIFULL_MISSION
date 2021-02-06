//
//  SCNVector3+CalculateDistance.swift
//  ARKit_LIFULL_MISSION
//
//  Created by ForAppleStoreAccount on 2021/02/07.
//

import SceneKit

extension SCNVector3 {
    static func calculateDistance(from startPoint: SCNVector3, to endPoint: SCNVector3) -> Float {
        let distance = sqrt(
            pow(startPoint.x - endPoint.x, 2) +
                pow(startPoint.y - endPoint.y, 2) +
                pow(startPoint.z - endPoint.z, 2)
        )

        return distance
    }
}
