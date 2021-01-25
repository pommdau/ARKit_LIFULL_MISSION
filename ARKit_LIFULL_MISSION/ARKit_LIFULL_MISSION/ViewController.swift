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
    
    private var dotNodes = [DotNode]() {
        didSet { configureActionButtonsUI() }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.scene = SCNScene()
        
        configureActionButtonsUI()
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
        guard let touchLocation = touches.first?.location(in: sceneView),
              let hitResult = sceneView.hitTest(touchLocation, types: .existingPlane).first else {
            return
        }
        
        let dotNode = DotNode(hitResult: hitResult)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
    }
    
    // MARK: - Actions
    
    @IBAction func undoButtonTapped(_ sender: UIButton) {
        guard dotNodes.count > 0 else { return }
        
        dotNodes.last?.removeFromParentNode()
        dotNodes.removeLast()
    }
    
    @IBAction func trashButtonTapped(_ sender: UIButton) {
        guard dotNodes.count > 0 else { return }
        
        for dotNode in dotNodes {
            dotNode.removeFromParentNode()
        }
        dotNodes.removeAll()
    }
    
    
    // MARK: - Helpers

    private func configureActionButtonsUI() {
        let existNode = dotNodes.count > 0
        undoButton.isEnabled = existNode
        trashButton.isEnabled = existNode
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(PlaneNode(anchor: planeAnchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let planeNode = node.childNodes.first as? PlaneNode else {
            return
        }
        
        planeNode.update(anchor: planeAnchor)
    }
}
