//
//  ViewController.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/01/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [DotNode]()
    var distanceLabelNodes = [DistanceLabelNode]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.scene = SCNScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Override Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [DotNode]()
            
            for distanceLabelNode in distanceLabelNodes {
                distanceLabelNode.removeFromParentNode()
            }
            distanceLabelNodes = [DistanceLabelNode]()
        }
        
        // タッチした2D座標 -> AR空間の3D座標
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .existingPlane)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    // MARK: - Helpers
    
    // MARK: Dot Rendering Methods
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotNode = DotNode(hitResult: hitResult)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(distance * 100)cm)", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        if distanceLabelNodes.count > 0 {
            distanceLabelNodes[0].removeFromParentNode()
        }
        print("DEBUG: \(distanceLabelNodes.count)")
        distanceLabelNodes.append(DistanceLabelNode(text: "sample", position: position))
        sceneView.scene.rootNode.addChildNode(distanceLabelNodes[0])
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(PlaneNode(anchor: planeAnchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        guard let planeNode = node.childNodes.first as? PlaneNode else { return }
        
        planeNode.update(anchor: planeAnchor)
    }
    
    
}
