# ARKit_LIFULL_MISSION

# 概要

- 概要は以下の通り
>[ARKit でお部屋の間取り画像を作ってみよう](https://techbowl.co.jp/techtrain/missions/5)
>ARKit で平面を認識する
>ARKit で認識した平面状にオブジェクトを設置する
>オブジェクトを順番に複数設定できるようにする
>オブジェクト同士が重なったことを検知して終了にする
>オブジェクトの各座標から距離を算出して、二次元状にプロットして位置関係を計算する
>画像に書き出す

- 求める成果物のイメージ
	- [LIFULL HOME’S iPhoneアプリがiOS11新機能「ARkit」に対応](https://lifull.com/news/10468/)

# GitHub

https://github.com/pommdau/ARKit_LIFULL_MISSION

# スクリーンショット

## 計測画面
- 初めに計測したい平面の検出を行います。

<img width="400" alt="image" src="https://imgur.com/n5xFMLc.jpg">

## 計測範囲の設定
- 平面の検出が行われたあと、画面をタップして点を追加します。
- 計測したい範囲を点で囲むように点を追加していってください。
- 左下のボタンは上からそれぞれ下記の動作を行います。
    - 追加されている点をすべて削除する
    - 追加されている最新の点を1つ削除する

<img width="400" alt="image" src="https://imgur.com/ewNcBDs.jpg">

## 計測結果画面
- 計測が完了したあと指定された範囲を表示します。

<img width="400" alt="image" src="https://imgur.com/xdYNoTe.jpg">

# 平面への点の追加ルール
- 最初の点(以下DotNodeと呼ぶ)は検出面のみを対象とする
  - 常に検出平面で近いものが採用されてしまうのを防ぐため
- 2つ目以降は検出面を無限に延長した面を対象とし、hitTestのうち最初のDotNodeともっともy座標の差が小さいものを採用する

```swift
let hitResults = dotNodes.isEmpty ?
    sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent) :
    sceneView.hitTest(touchLocation, types: .existingPlane)
```

# 計測画面の状態管理

- 下記の動きを制御するために状態をenum定義
    - `isShowingResultView`のときマッピングを停止させる
    - 上部のステータスラベルの表示を切り替える。(`configureStatusLabel()`)

```swift
private enum MappingStatus {
    case notReady            // マッピングの準備がまだの状態
    case notDetectedPlain    // 平面がまだ検出されていない状態
    case detectedFirstPlain  // 初めて平面が検出された状態
    case detectedPlain       // 2つ以上の平面が検出された状態
    case isShowingResultView // 結果ビューが表示中の状態
}
```

# 計測座標の画像への書き出し

## 3次元座標->2次元座標への変換
- DotNodeが同一平面に収まっているという前提で下記の通り変換を行う

```swift
typealias Coordinate = simd_float2
------------------------------------------
class DotNode: SCNNode {
    // ...
    func convertToCoordinate() -> Coordinate {
        Coordinate(position.x, position.z)
    }
}
```

## 画像作成の流れ
- `UIView`のカスタムクラスを作成しそこで描画を行う。
- 最後にサイズを指定して`UIView`を`UIImage`に変換する流れ。

```swift
let resultImageView = ResultImageView(dotCoordinates: dotCoordinates)
resultImageView.frame.size = CGSize(width: 1024, height: 1024)
guard let image = resultImageView.convertToImage() else {
    return nil
}
```

## 座標の変換
- 具体的なコードは[CoordinateManager.swift](https://github.com/pommdau/ARKit_LIFULL_MISSION/blob/main/ARKit_LIFULL_MISSION/ARKit_LIFULL_MISSION/ResultImageView/CoordinateManager.swift)を参照

### ①: 座標の変換
- 回転行列を使って特定の辺が画面横に向かって平行になるように全座標を回転させる。
    - 今回は最大の辺が並行になるように回転を行う。
- [Working with Matrices ](https://developer.apple.com/documentation/accelerate/working_with_matrices)
    - Swiftでの回転行列の作成と座標変換

### ③: 全座標のx,y座標の値が0以上の値になるよう平行移動させる
- 全座標のx,y座標の最小値を取り、それらを全座標の値から引いてやれば良い。

### ④ ⑤: 座標値を描画範囲に対する％へ変換
- 最終的に、今のドットの座標を与えられた描画範囲(0-100%)に対して何%の位置に描画するかとしての割合に変換したい。
- よって座標を0-100の範囲に収まるように変換を行う。
- また今回はViewで描画する際周りに5%のマージンを持たせるので、5-95の範囲に収まるように変換を行う。
- まず画像の④の通り0-90の範囲で座標を変換し、⑤の通りマージンの5%分を加えて5-95の範囲へと補正を行う。

<img width="512" alt="image" src="https://imgur.com/qSYawgo.jpg">

### ⑥: 中央に描画されるように座標変換
- 最後に描画する図形が中央に位置するように座標の補正を行う。

<img width="512" alt="image" src="https://imgur.com/QMSZ4Bu.jpg">

# その他得られた知見
## ステートメントを必要としないメソッドをExtensionとして定義する

- 下記のような状態によって変わらない、単純な変数だけのメソッドはextensionに切り分けるといい。

```swift
extension SCNVector3 {
    static func calculateDistance(from startPoint: SCNVector3, to endPoint: SCNVector3) -> Float {
        let distance = sqrt(
            pow(startPoint.x - endPoint.x, 2) +
                pow(startPoint.y - endPoint.y, 2) +
                pow(startPoint.z - endPoint.z, 2)
        )

        return distance
    }
}
```

## SwiftLintの導入
- SwiftLintを導入した。設定や導入方法は下記の通り。
	- [pommdau/SwiftLint\-Config](https://github.com/pommdau/SwiftLint-Config)
- ルール定義の`.yml`ファイルはリモートに置いて置くと使い回せて便利。

## デバッグ設定の分離
- Releaseのときファイルをコンパイルしないように設定と`#ifdef DEBUG`により、デバッグ部分が誤ってリリースされないようにしておく。
	- [iOSで開発向け機能の実装する時に使うテクニック](https://qiita.com/t_osawa_009/items/6080037f20acdec1b239)
- 以下の通りSuffixを指定し、Releaseで`*+Debug.swift`のファイルを無視するように設定する

<img width="512" alt="image" src="https://i.imgur.com/fJeg6aG.png">

- 上記の命名規則に則り`MappingViewController+Debug.swift`というファイルを作成し、デバッグ用のメソッドを書く。

```swift
extension MappingViewController {
    // status labelのテスト用
    func getNextMappintStatus(mappingStatus: MappingStatus) -> MappingStatus {
		// ry
    }

    // 結果画面のテスト用
    func presentDebugResultView() {
       // ry      
    }
}
```

- 本体のコードには`#ifdef DEBUG`でリリース時にコンパイルされないようにしておく。

```swift
    #if DEBUG
    private lazy var debugButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Show Debug ResultView", for: .normal)
        button.layer.cornerRadius = 5
        button.setDimensions(width: 250, height: 40)
        button.addTarget(self, action: #selector(debugButtonTapped(_:)), for: .touchUpInside)

        return button
    }()
    #endif
```

## typealiasの話
- `typealias`は`struct`に対しては安全で問題ないとのこと
    - [simd\_float2 \| Apple Developer Documentation](https://developer.apple.com/documentation/simd/simd_float2): structですね。
- 一方`Class`に対しては参照が伴うので危険。

```swift
typealias Coordinate = simd_float2  // これは安全
```

## テストコードの話
- ステートメントを伴わない関数はテストコードが書きやすい。
- extensionの一部でテストコードを書いてみた。
    - [Xcode11\.6で既存プロジェクトにUnitTestを追加する方法](https://program-life.com/1772)
    - テストの書き方はSwift実践入門を参考にした

```swift
//  ARKit_LIFULL_MISSIONTests.swift
//  ARKit_LIFULL_MISSIONTests

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
```

# 参考
- [詳細! Swift 4 iPhoneアプリ開発 入門ノート Swift 4](www.amazon.co.jp/dp/4800711843)
	- ARの触りとして。解説が詳しくないので補足は別途必要そう。
- [iOS & Swift \- The Complete iOS App Development Bootcamp \| Udemy](https://www.udemy.com/course/ios-13-app-development-bootcamp/)のARパート
	- 平面検出やNodeの作成方法など、AR周りの基本を参照。
- [\[Swift 4\] UIBezierPathを使って遊んでみる\(その1\) \| DevelopersIO](https://dev.classmethod.jp/articles/play-uibezierpath-1/)<br>[\[Swift 4\] UIBezierPathを使って遊んでみる\(その2\) \| DevelopersIO](https://dev.classmethod.jp/articles/play-uibezierpath-2/)
    - 描画や座標の扱いに関して主に参考にした。
- Swift実践入門
    - 諸々の文法等で参考にした。
- [UIViewからUIImageを生成する](https://qiita.com/k-yamada-github/items/f0a90a6e91f38bd6d9b9)<br>[【iOS】UIViewをUIImageに変換する \- Iganinのブログ](https://iganin.hatenablog.com/entry/2020/05/11/070950)
    - `UIView`から`UIImage`への変換
