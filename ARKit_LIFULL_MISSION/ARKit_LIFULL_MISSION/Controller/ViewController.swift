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

    // MARK: - Definitions

    enum MappingStatus {
        case notDetectedPlain
        case detectedPlain
        case addedDotNode
        case finishMapping
    }

    // MARK: - Properties

    private var dotNodes = [DotNode]() {
        didSet { configureActionButtonsUI() }
    }

    private var branchNodes = [BranchNode]()

    private lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        return sceneView
    }()

    private var mappingStatus = MappingStatus.notDetectedPlain {
        didSet {
            configureStatusLabel()
        }
    }

    // MARK: - UI Properties

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .init(white: 0.0, alpha: 0.5)
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.setDimensions(height: 60)
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        return label
    }()

    private lazy var undoButton: UIButton = {
        let button = createActionButton(withSystemName: "arrow.uturn.backward")
        button.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var trashButton: UIButton = {
        let button = createActionButton(withSystemName: "trash.fill")
        button.addTarget(self, action: #selector(trashButtonTapped(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var debugButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Show Debug ResultView", for: .normal)
        button.layer.cornerRadius = 5
        button.setDimensions(width: 250, height: 40)
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

        initializeUI()
        configureActionButtonsUI()
        configureStatusLabel()
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

    // MARK: - Override

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

            // 結果画像を表示するビューの表示
            let coordinates = dotNodes.map { dotNode in dotNode.convertToCoordinate() }
            let controller = ResultViewController(withDotCoordinates: coordinates)
            present(controller, animated: true) {
                self.removeAllNodes()
            }

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

    @objc
    private func undoButtonTapped(_ sender: UIButton) {
        undoAddingDotNode()
    }

    @objc
    private func trashButtonTapped(_ sender: UIButton) {
        removeAllNodes()
    }

    @objc
    private func debugButtonTapped(_ sender: UIButton) {
        if mappingStatus == .notDetectedPlain {
            mappingStatus = .detectedPlain
        } else {
            mappingStatus = .notDetectedPlain
        }

        //        let controller = ResultViewController(withDotCoordinates: [
        //            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
        //            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
        //            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
        //            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10))
        //        ])
        //        present(controller, animated: true, completion: nil)
    }

    // MARK: - Helpers

    // MARK: Configure UI Methods

    private func createActionButton(withSystemName systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .init(white: 1.0, alpha: 0.8)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.layer.cornerRadius = 5
        button.setDimensions(width: 100, height: 40)

        return button
    }

    private func initializeUI() {
        view.addSubview(sceneView)
        sceneView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)

        view.addSubview(statusLabel)
        statusLabel.centerX(inView: view)
        statusLabel.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                           paddingTop: 0, paddingLeft: 0, paddingRight: 0)

        let buttonStack = UIStackView(arrangedSubviews: [undoButton, trashButton, debugButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 8
        buttonStack.distribution = .fillProportionally
        view.addSubview(buttonStack)
        buttonStack.centerX(inView: view)
        buttonStack.anchor(bottom: view.bottomAnchor, paddingBottom: 100)
    }

    private func configureStatusLabel() {
        DispatchQueue.main.async {
            switch self.mappingStatus {
            case .notDetectedPlain:
                self.statusLabel.text = "平面を検出中です…"
                self.statusLabel.alpha = 1.0
                self.statusLabel.isHidden = false
            case .detectedPlain:
                UIView.animate(withDuration: 0.5) {
                    self.statusLabel.alpha = 0
                } completion: { _ in
                    self.statusLabel.isHidden = true
                }
            case .addedDotNode, .finishMapping:
                break
            }
        }
    }

    private func configureActionButtonsUI() {
        let existsNode = !dotNodes.isEmpty
        undoButton.isEnabled = existsNode
        trashButton.isEnabled = existsNode
    }

    // MARK: Handle Node Methods

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

        if SCNVector3.calculateDistance(from: newDotNode.position, to: startingDotNode.position) <= 0.03 {  // 始点から3cm以内であればマッピングを終了とする
            return true
        }

        return false
    }
}

// MARK: - ARSCNViewDelegate Methods

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        if mappingStatus == .notDetectedPlain {
            mappingStatus = .detectedPlain
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
