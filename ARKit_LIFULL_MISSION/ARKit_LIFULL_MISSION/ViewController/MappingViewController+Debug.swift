//
//  MappingViewController+Debug.swift
//  ARKit_LIFULL_MISSION
//
//  Created by ForAppleStoreAccount on 2021/02/10.
//

import Foundation

extension MappingViewController {

    // status labelのテスト用
    func getNextMappintStatus(mappingStatus: MappingStatus) -> MappingStatus {
        switch mappingStatus {
        case .notReady:
            return .notDetectedPlain
        case .notDetectedPlain:
            return .detectedFirstPlain
        case .detectedFirstPlain:
            return .detectedPlain
        case .detectedPlain:
            return .isShowingResultView
        case .isShowingResultView:
            return .notReady
        }
    }

    // 結果画面のテスト用
    func presentDebugResultView() {
        let controller = ResultViewController(withDotCoordinates: [
            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10)),
            Coordinate(Float.random(in: -10...10), Float.random(in: -10...10))
        ])
        present(controller, animated: true, completion: nil)
    }
}
