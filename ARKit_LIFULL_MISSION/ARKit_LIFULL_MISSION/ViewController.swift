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
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    
    private var dotNodes = [DotNode]()
    
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
        // タッチした2D座標 -> AR空間の3D座標        
        guard
            let touchLocation = touches.first?.location(in: sceneView),
            let hitResult = sceneView.hitTest(touchLocation, types: .existingPlane).first else {
            return
        }
        
        let dotNode = DotNode(hitResult: hitResult)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
    }
    
    // MARK: - Actions
    
    @IBAction func undoButtonTapped(_ sender: UIButton) {
        print("DEBUG: undoButtonTapped")
    }
    
    @IBAction func trashButtonTapped(_ sender: UIButton) {
        print("DEBUG: trashButtonTapped")
    }
    
    
    // MARK: - Helpers

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
