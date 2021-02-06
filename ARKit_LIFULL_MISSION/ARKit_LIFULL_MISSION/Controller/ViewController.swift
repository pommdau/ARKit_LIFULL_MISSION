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

    @IBOutlet private var sceneView: ARSCNView!
    @IBOutlet private weak var undoButton: UIButton!
    @IBOutlet private weak var trashButton: UIButton!

    private var dotNodes = [DotNode]() {
        didSet { configureActionButtonsUI() }
    }

    private var branchNodes = [BranchNode]()  // DotNode間に配置する線分オブジェクト

    private lazy var debugButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("debug button", for: .normal)
        button.addTarget(self, action: #selector(debugButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.scene = SCNScene()

        configureUI()
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

        // 適切なHitResultを取得する
        // タッチした2D座標 -> AR空間の3D座標
        guard let touchLocation = touches.first?.location(in: sceneView) else {
            return
        }

        let hitResults = dotNodes.isEmpty ?
            sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent) :
            sceneView.hitTest(touchLocation, types: .existingPlane)

        // hitResultsはカメラから近い順にソートされている
        guard let firstHitResult = hitResults.first else {
            return
        }
        var suitableHitResult = firstHitResult

        // ドットがすでに1つ以上追加されている場合、最初のDotNodeに最もy座標が近い平面の結果を採用する
        if let startDotNode = dotNodes.first {
            var minYDifference = Float.greatestFiniteMagnitude
            hitResults.forEach { hitResult in
                let yDifference = abs(startDotNode.position.y - hitResult.worldTransform.columns.3.y)
                if yDifference < minYDifference {
                    minYDifference = yDifference
                    suitableHitResult = hitResult
                }
            }
        }

        let dotNode = dotNodes.isEmpty ?
            DotNode(hitResult: suitableHitResult, color: .lifullBrandColor) :
            DotNode(hitResult: suitableHitResult)

        // 計測完了かどうかを確認する
        if needsFinishMapping(withDotNode: dotNode),
           let startPosition = dotNodes.last?.position,
           let endPosition = dotNodes.first?.position {
            let branchNode = BranchNode(from: startPosition,
                                        to: endPosition)
            branchNodes.append(branchNode)
            sceneView.scene.rootNode.addChildNode(branchNode)

            showFinishMappingDialog()

            return
        }

        // タップされた位置にDotNodeを追加
        // TODO: この辺のBranchNodeの処理はまとめられそう
        dotNodes.append(dotNode)
        sceneView.scene.rootNode.addChildNode(dotNode)

        // DotNode間にBranchNodeを追加
        if dotNodes.count >= 2 {
            let branchNode = BranchNode(from: dotNodes[dotNodes.count - 2].position,
                                        to: dotNodes[dotNodes.count - 1].position)
            branchNodes.append(branchNode)
            sceneView.scene.rootNode.addChildNode(branchNode)
        }

    }

    // MARK: - Actions

    @IBAction private func undoButtonTapped(_ sender: UIButton) {
        undoAddingDotNode()
    }

    @IBAction private func trashButtonTapped(_ sender: UIButton) {
        removeAllNodes()
    }

    @IBAction private func debugButtonTapped(_ sender: UIButton) {
        let controller = ResultViewController()
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Helpers

    private func configureUI() {
        view.addSubview(debugButton)
        debugButton.centerX(inView: view)
        debugButton.anchor(bottom: view.bottomAnchor, paddingBottom: 100)
        debugButton.setDimensions(width: 100, height: 40)
    }

    private func configureActionButtonsUI() {
        let existsNode = !dotNodes.isEmpty
        undoButton.isEnabled = existsNode
        trashButton.isEnabled = existsNode
    }

    private func undoAddingDotNode() {
        guard !dotNodes.isEmpty else {
            return
        }

        // 直前のBranchNodeを削除
        if dotNodes.count >= 2 {
            branchNodes.last?.removeFromParentNode()
            branchNodes.removeLast()
        }

        // 直前のDotNodeを削除
        dotNodes.last?.removeFromParentNode()
        dotNodes.removeLast()
    }

    private func removeAllNodes() {
        guard !dotNodes.isEmpty else {
            return
        }

        for dotNode in dotNodes {
            dotNode.removeFromParentNode()
        }
        dotNodes.removeAll()

        for branchNode in branchNodes {
            branchNode.removeFromParentNode()
        }
        branchNodes.removeAll()
    }

    private func needsFinishMapping(withDotNode newDotNode: DotNode) -> Bool {

        // マッピングは点が3つ以上でないと終了させない
        guard dotNodes.count >= 2 ,
              let startingDotNode = dotNodes.first else {
            return false
        }

        if calculateDistance(from: newDotNode.position, to: startingDotNode.position) <= 0.03 {  // 始点から3cm以内であればマッピングを終了とする
            return true
        }

        return false
    }

    private func showFinishMappingDialog() {
        let alertController = UIAlertController(title: "計測が完了しました！", message: "", preferredStyle: .alert)

        alertController.addAction(
            UIAlertAction(title: "結果を見る",
                          style: .default) { _ in
                print("DEBUG: 結果を表示するダイアログへ遷移させる")
            })

        alertController.addAction(
            UIAlertAction(title: "最初からやり直す",
                          style: .destructive) { _ in
                self.removeAllNodes()
            })
        self.present(alertController, animated: true, completion: nil)
    }

    private func calculateDistance(from startPoint: SCNVector3, to endPoint: SCNVector3) -> Float {
        let distance = sqrt(
            pow(startPoint.x - endPoint.x, 2) +
                pow(startPoint.y - endPoint.y, 2) +
                pow(startPoint.z - endPoint.z, 2)
        )

        return distance
    }
}

// MARK: - ARSCNViewDelegate Methods

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
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
