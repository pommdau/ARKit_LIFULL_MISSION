//
//  ARKit_LIFULL_MISSIONTests.swift
//  ARKit_LIFULL_MISSIONTests
//
//  Created by ForAppleStoreAccount on 2021/02/11.
//

import XCTest
import SceneKit
@testable import ARKit_LIFULL_MISSION

class ARKit_LIFULL_MISSIONTests: XCTestCase {

    func testSCNVector3_CalculateDistance() {
        XCTAssertEqual(
            SCNVector3.calculateDistance(from: SCNVector3(0, 0, 0), to: SCNVector3(10, 20, 30)),
            sqrt(1400)
        )
    }
    
    func testCoordinate_CalculateDistance() {
        XCTAssertEqual(
            Coordinate.calculateDistance(from: Coordinate(0, 0), to: Coordinate(10, 20)),
            sqrt(500)
        )
    }
    
}
