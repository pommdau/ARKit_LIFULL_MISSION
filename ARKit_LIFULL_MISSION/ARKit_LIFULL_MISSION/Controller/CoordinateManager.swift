//
//  CoordinateManager.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/02/03.
//

import Foundation
import SceneKit

struct CoordinateManager {
    
    // MARK: - Properties
    
    private static let drawingMergin: Float = 5  // 描画範囲の周りにマージンをとる(e.g. 5:=5%)
    
    // MARK: - Helpers
    
    // MARK: Rotation Methods
    
    static func rotate(withCoordinates coordinates: [Coordinate]) -> [Coordinate] {
        let rotationMatrix = Self.makeRotationMatrix(angle: Self.calculateRotationRadian(withCoordinates: coordinates))
        let rotatedCoordinates: [Coordinate] = coordinates.map({ coordinate in rotationMatrix * coordinate })
        
        return rotatedCoordinates
    }
    
    // 回転行列の作成
    // [Working with Matrices](https://developer.apple.com/documentation/accelerate/working_with_matrices)
    static private func makeRotationMatrix(angle: Float) -> simd_float2x2 {
        let rows = [
            simd_float2( cos(angle), sin(angle)),
            simd_float2(-sin(angle), cos(angle)),
        ]
        
        return float2x2(rows: rows)
    }
    
    // 最も長い辺が横に並行になるような角度を計算する
    static private func calculateRotationRadian(withCoordinates coordinates: [Coordinate]) -> Float {
        
        if coordinates.count < 2 { return 0 }
        
        var indexes = (first: 0, second: 1)  // 回転角を決める2点のインデックス
        // 最長の辺を持つ2点を計算する
        var maxDistance = -Float.greatestFiniteMagnitude
        for (i, _) in coordinates.enumerated() {
            // 最後のインデックスの場合、最初の点との距離を測る
            let next_i = (i == coordinates.count - 1) ? 0 : i + 1
            let distance = Self.calculateDistance(from: coordinates[i], to: coordinates[next_i])
            
            if maxDistance < distance {
                maxDistance = distance
                indexes = (i, next_i)
            }
        }
        
        let a = coordinates[indexes.first]
        let b = coordinates[indexes.second]
        let theta = atan2(b.y - a.y, b.x - a.x)
        
        return theta
    }
    
    static private func calculateDistance(from startPoint: Coordinate, to endPoint: Coordinate) -> Float {
        let distance = sqrt(
            pow(startPoint.x - endPoint.x, 2) +
            pow(startPoint.y - endPoint.y, 2)
        )
        
        return distance
    }
    
    // MARK: Correnct Coordinate Methods
    
    static func minX(withCoordinates coordinates: [Coordinate]) -> Float {
        var minX =  Float.greatestFiniteMagnitude
        coordinates.forEach { coordinate in
            minX = min(coordinate.x, minX)
        }
        
        return minX
    }
    
    static func minY(withCoordinates coordinates: [Coordinate]) -> Float {
        var minY =  Float.greatestFiniteMagnitude
        coordinates.forEach { coordinate in
            minY = min(coordinate.y, minY)
        }
        
        return minY
    }
    
    static func maxX(withCoordinates coordinates: [Coordinate]) -> Float {
        var maxX =  -Float.greatestFiniteMagnitude
        coordinates.forEach { coordinate in
            maxX = max(coordinate.x, maxX)
        }
        
        return maxX
    }
    
    static func maxY(withCoordinates coordinates: [Coordinate]) -> Float {
        var maxY =  -Float.greatestFiniteMagnitude
        coordinates.forEach { coordinate in
            maxY = max(coordinate.y, maxY)
        }
        
        return maxY
    }
    
    static func differenceX(withCoordinates coordinates: [Coordinate]) -> Float {
        let minX = Self.minX(withCoordinates: coordinates)
        let maxX = Self.maxX(withCoordinates: coordinates)
        
        return maxX - minX
    }
    
    static func differenceY(withCoordinates coordinates: [Coordinate]) -> Float {
        let minY = Self.minY(withCoordinates: coordinates)
        let maxY = Self.maxY(withCoordinates: coordinates)
        
        return maxY - minY
    }
    
    // 座標を0-100の値に変換する
    // 画像サイズに対して何%の位置に座標があるか、として扱うため
    static func convertCoordinatesToPercentages(withCoordinates coordinates: [Coordinate]) -> [Coordinate] {
        
        // まず全座標の最小のx座標を0、最小のy座標を0となるようにする
        let minX = Self.minX(withCoordinates: coordinates)
        let minY = Self.minY(withCoordinates: coordinates)
        var correctedCoordinates = coordinates.map({ coordinate in
            Coordinate(coordinate.x - minX, coordinate.y - minY)
        })
        
        // 次に全座標の値を0-90(マージンが5%の場合)に収める
        let ratioX = (100 - drawingMergin * 2) / Self.differenceX(withCoordinates: correctedCoordinates)
        let ratioY = (100 - drawingMergin * 2) / Self.differenceY(withCoordinates: correctedCoordinates)
        let ratio = min(ratioX, ratioY)  // より小さい倍率を採用する 0.5倍と2倍なら0.5倍
        correctedCoordinates =
            correctedCoordinates.map({ coordinate in
                Coordinate(coordinate.x * ratio, coordinate.y * ratio)
            })
        
        // マージンを加えて5-95%の数値に収める
        // また中央に描画されるように縦横いずれか短い方に下駄を履かせる
        var merginX = drawingMergin
        var merginY = drawingMergin
        let differenceX = Self.differenceX(withCoordinates: correctedCoordinates)
        let differenceY = Self.differenceY(withCoordinates: correctedCoordinates)
        if differenceX < differenceY {
            // 縦長の場合
            merginX += ((100 - drawingMergin * 2) - differenceX) / 2
        } else {
            // 横長の場合
            merginY += ((100 - drawingMergin * 2) - differenceY) / 2
        }
        correctedCoordinates =
            correctedCoordinates.map({ coordinate in
                Coordinate(coordinate.x + merginX, coordinate.y + merginY)
            })
        
        return correctedCoordinates
    }
}
