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
        
        let dotNode = dotNodes.isEmpty ? DotNode(hitResult: hitResult, color: .lifullBrandColor) : DotNode(hitResult: hitResult)
        
        if needsFinishMapping(withDotNode: dotNode) {
            print("DEBUG: マッピングを終了します")
            showFinishMappingDialog()
            return
        }
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
    }
    
    // MARK: - Actions
    
    @IBAction func undoButtonTapped(_ sender: UIButton) {
        undoAddingDotNode()
    }
    
    @IBAction func trashButtonTapped(_ sender: UIButton) {
        removeAllDotNodes()
    }
    
    // MARK: - Helpers
    
    private func configureActionButtonsUI() {
        let existNode = dotNodes.count > 0
        undoButton.isEnabled = existNode
        trashButton.isEnabled = existNode
    }
    
    private func undoAddingDotNode() {
        guard dotNodes.count > 0 else { return }
        
        dotNodes.last?.removeFromParentNode()
        dotNodes.removeLast()
    }
    
    private func removeAllDotNodes() {
        guard dotNodes.count > 0 else { return }
        
        for dotNode in dotNodes {
            dotNode.removeFromParentNode()
        }
        dotNodes.removeAll()
    }
        
    private func needsFinishMapping(withDotNode newDotNode: DotNode) -> Bool {
        
        guard dotNodes.count >= 2 else { return false }  // マッピングは点が3つ以上でないと終了させない
        
        let startDotNode = dotNodes.first!
        let distance = sqrt(
            pow(newDotNode.position.x - startDotNode.position.x, 2) +
            pow(newDotNode.position.y - startDotNode.position.y, 2) +
            pow(newDotNode.position.z - startDotNode.position.z, 2)
        )
        
        if distance <= 0.03 {  // 始点から3cm以内であればマッピングを終了とする
            return true
        }
        
        return false
    }
    
    private func showFinishMappingDialog() {
        let alertController = UIAlertController(title: "計測が完了しました！", message: "", preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: "結果を見る",
                          style: .default,
                          handler: { _ in
                            print("DEBUG: 結果を表示するダイアログへ遷移させる")
                          }))
        
        alertController.addAction(
            UIAlertAction(title: "最初からやり直す",
                          style: .destructive,
                          handler: { _ in
                            self.trashButtonTapped(UIButton())
                          }))
        self.present(alertController, animated: true, completion: nil)
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
