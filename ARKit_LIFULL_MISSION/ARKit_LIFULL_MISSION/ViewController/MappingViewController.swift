//
//  ViewController.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/01/24.
//

import UIKit
import SceneKit
import ARKit

class MappingViewController: UIViewController {

    // MARK: - Enum

    private enum MappingStatus {
        case notReady            // マッピングの準備がまだの状態
        case notDetectedPlain    // 平面がまだ検出されていない状態
        case detectedFirstPlain  // 初めて平面が検出された状態
        case detectedPlain       // 2つ以上の平面が検出された状態
        case isShowingResultView // 結果ビューが表示中の状態
    }

    // MARK: - Properties

    private var dotNodes = [DotNode]() {
        didSet {
            configureActionButtonsUI()
        }
    }

    private var branchNodes = [BranchNode]()

    private var mappingStatus = MappingStatus.notReady {
        didSet {
            configureStatusLabel()
        }
    }

    // MARK: - UI Properties

    private lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        return sceneView
    }()

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

    private lazy var trashButton: UIButton = {
        let button = createActionButton(withSystemName: "trash.fill")
        button.addTarget(self, action: #selector(trashButtonTapped(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var undoButton: UIButton = {
        let button = createActionButton(withSystemName: "arrow.uturn.backward")
        button.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)

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

        initializeUI()
        configureActionButtonsUI()
        configureStatusLabel()
        mappingStatus = .notDetectedPlain
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        sceneView.session.run(configuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if mappingStatus == .notReady {
            mappingStatus = .notDetectedPlain
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    // MARK: - Override

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let dotNode = createDotNode(withTouches: touches) else {
            return
        }

        // 計測完了かどうかを確認する
        if needsFinishMapping(withAddedDotNode: dotNode),
           let startPosition = dotNodes.last?.position,
           let endPosition = dotNodes.first?.position {

            let branchNode = BranchNode(from: startPosition,
                                        to: endPosition)
            branchNodes.append(branchNode)
            sceneView.scene.rootNode.addChildNode(branchNode)

            // 結果画像を表示するビューの表示
            let coordinates = dotNodes.map { dotNode in dotNode.convertToCoordinate() }
            let controller = ResultViewController(withDotCoordinates: coordinates)
            controller.delegate = self
            present(controller, animated: true) {
                self.mappingStatus = .isShowingResultView
                self.removeAllNodes()
            }

            return
        }

        // タップされた位置にDotNodeを追加
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
        /*
         // 1. status labelのテスト用
         switch mappingStatus {
         case .notReady:
         mappingStatus = .notDetectedPlain
         case .notDetectedPlain:
         mappingStatus = .detectedFirstPlain
         case .detectedFirstPlain:
         mappingStatus = .detectedPlain
         case .detectedPlain:
         mappingStatus = .isShowingResultView
         case .isShowingResultView:
         mappingStatus = .notReady
         }

         // 2. 結果画面のテスト用
         let controller = ResultViewController(withDotCoordinates: [
         Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
         Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
         Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
         Coordinate(Float.random(in: -10...10), Float.random(in: -10...10))
         ])
         present(controller, animated: true, completion: nil)
         */
    }

    // MARK: - Helpers

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

        sceneView.delegate = self
        sceneView.scene = SCNScene()

        // AutoLayout
        view.addSubview(sceneView)
        sceneView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)

        view.addSubview(statusLabel)
        statusLabel.centerX(inView: view)
        statusLabel.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                           paddingTop: 0, paddingLeft: 0, paddingRight: 0)

        let actionButtonStack = UIStackView(arrangedSubviews: [trashButton, undoButton])
        actionButtonStack.axis = .vertical
        actionButtonStack.spacing = 20
        actionButtonStack.distribution = .fillProportionally
        view.addSubview(actionButtonStack)
        actionButtonStack.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                                 paddingLeft: 20, paddingBottom: 20)

        // DEBUG用の設定
        if ProcessInfo.processInfo.environment["DEBUGGING"] == "1" {
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

            view.addSubview(debugButton)
            debugButton.centerX(inView: view)
            debugButton.anchor(bottom: actionButtonStack.topAnchor, paddingBottom: 20)
        }
    }

    private func configureStatusLabel() {
        DispatchQueue.main.async {
            switch self.mappingStatus {

            case .notReady:
                self.statusLabel.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.statusLabel.text = "計測の準備中です…"
                    self.statusLabel.alpha = 1.0
                }

            case .notDetectedPlain:
                self.statusLabel.text = "平面を検出中です…"

            case .detectedFirstPlain:
                self.statusLabel.text = "平面が検出されました！"

            case .detectedPlain:
                UIView.animate(withDuration: 0.5) {
                    self.statusLabel.alpha = 0
                } completion: { _ in
                    self.statusLabel.isHidden = true
                }

            case .isShowingResultView:
                break
            }
        }
    }

    private func configureActionButtonsUI() {
        let existsNode = !dotNodes.isEmpty
        undoButton.isEnabled = existsNode
        trashButton.isEnabled = existsNode
    }
}

// MARK: - Node Handling Methods

extension MappingViewController {

    private func createDotNode(withTouches touches: Set<UITouch>) -> DotNode? {

        // タッチされた2D座標 -> AR空間の3D座標
        // また結果ビューの表示中はDotNodeを追加しない
        guard let touchLocation = touches.first?.location(in: sceneView) ,
              mappingStatus != MappingStatus.isShowingResultView else {
            return nil
        }

        // 最初のDotNodeは検出面のみが対象
        // 2つめ以降は検出面を無限に延長した面を対象とする
        let hitResults = dotNodes.isEmpty ?
            sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent) :
            sceneView.hitTest(touchLocation, types: .existingPlane)

        // hitResultsはカメラから近い順にソートされている
        guard var suitableHitResult = hitResults.first else {
            return nil
        }

        // 初めてのDotNodeの追加の場合、カメラから近い平面のHitResultを採用する
        // 2つ目以降のDotNodeの追加の場合、最初のDotNodeに対して最もy座標が近い平面のHitResultの結果を採用する
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

        let position = SCNVector3(
            x: suitableHitResult.worldTransform.columns.3.x,
            y: suitableHitResult.worldTransform.columns.3.y,
            z: suitableHitResult.worldTransform.columns.3.z
        )
        let dotNode = dotNodes.isEmpty ?
            DotNode(position: position, color: .lifullBrandColor) :
            DotNode(position: position)

        return dotNode
    }

    private func undoAddingDotNode() {
        guard !dotNodes.isEmpty else {
            return
        }

        // DotNodeが2つ以上ある場合に、最新のBranchNodeを削除
        if dotNodes.count >= 2 {
            branchNodes.last?.removeFromParentNode()
            branchNodes.removeLast()
        }

        // 最新のDotNodeを削除
        dotNodes.last?.removeFromParentNode()
        dotNodes.removeLast()
    }

    private func removeAllNodes() {
        guard !dotNodes.isEmpty else {
            return
        }

        dotNodes.forEach { dotNode in dotNode.removeFromParentNode() }
        dotNodes.removeAll()
        branchNodes.forEach { branchNode in branchNode.removeFromParentNode() }
        branchNodes.removeAll()
    }

    private func needsFinishMapping(withAddedDotNode addedDotNode: DotNode) -> Bool {

        // マッピングは点が3つ以上でないと終了させない
        guard dotNodes.count >= 2 ,
              let firstDotNode = dotNodes.first else {
            return false
        }

        // 始点から5cm以内であればマッピングを終了とする
        return SCNVector3.calculateDistance(from: addedDotNode.position, to: firstDotNode.position) <= 0.05
    }
}

// MARK: - ARSCNViewDelegate Methods

extension MappingViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }

        switch mappingStatus {
        case .notDetectedPlain:
            mappingStatus = .detectedFirstPlain
        case .detectedFirstPlain:
            mappingStatus = .detectedPlain
        default:
            break
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

// MARK: - ARSCNViewDelegate Methods

extension MappingViewController: ResultViewControllerDelegate {
    func resultViewControllerDidDissappear(_ resultViewController: ResultViewController) {
        mappingStatus = .detectedPlain
    }
}
