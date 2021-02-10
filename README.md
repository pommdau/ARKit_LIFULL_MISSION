# ARKit_LIFULL_MISSION

# 概要

- 概要は以下のページ 
>[ARKit でお部屋の間取り画像を作ってみよう](https://techbowl.co.jp/techtrain/missions/5)
>ARKit で平面を認識する
>ARKit で認識した平面状にオブジェクトを設置する
>オブジェクトを順番に複数設定できるようにする
>オブジェクト同士が重なったことを検知して終了にする
>オブジェクトの各座標から距離を算出して、二次元状にプロットして位置関係を計算する
>画像に書き出す

- 求める成果物のイメージ
	- [LIFULL HOME’S iPhoneアプリがiOS11新機能「ARkit」に対応](https://lifull.com/news/10468/)

# ScreenShots

## 計測画面

<img width="512" alt="image" src="https://imgur.com/Fc77I2D.png">

## 計測範囲の設定

<img width="512" alt="image" src="https://imgur.com/59xhlq7.png">

## 計測結果画面

<img width="512" alt="image" src="https://imgur.com/aBiP6VD.png">

# DotNodeの平面追加のロジック

- 最初のDotNodeは検出面のみを対象とする
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
func convertToCoordinate() -> Coordinate {
    Coordinate(position.x, position.z)
}
```

## 画像作成の流れ
- `UIView`のカスタムクラスを作成しそこで描画を行う。
- 最後にサイズを指定して`UIView`を`UIImage`に変換する流れ

```swift
let resultImageView = ResultImageView(dotCoordinates: dotCoordinates)
resultImageView.frame.size = CGSize(width: 1024, height: 1024)
guard let image = resultImageView.convertToImage() else {
    return nil
}
```

## 座標の変換

### 1. 座標の変換
- [Working with Matrices ](https://developer.apple.com/documentation/accelerate/working_with_matrices)

<img width="512" alt="image" src="https://imgur.com/qSYawgo.jpg">

<img width="512" alt="image" src="https://imgur.com/QMSZ4Bu.jpg">



# その他得られた知見
## ステートメントを必要としないメソッドはExtensionとして定義する

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
- 色々指摘してもらえるので、まず入れておくと間違いないなと感じた。(私はSwiftLint先生と呼んでいる)
- ルール定義の`.yml`ファイルはリモートに置いて使い回せるのが便利。

# デバッグ設定の切り替え

- デバッグ用にボタンを表示したかったので以下の通り設定
	- [特定のSchemeのときにのみ、プログラムを実行させる（Xcode, Swift）](htt-ps://zenn.dev/ikeh1024/articles/9921957ca6e041920aec)
- デバッグ用のSchemeを作成し環境変数を設定する

![image](https://i.imgur.com/ql4sp0d.png)

```swift
// DEBUG用の設定
if ProcessInfo.processInfo.environment["DEBUGGING"] == "1" {
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

    view.addSubview(debugButton)
    debugButton.centerX(inView: view)
    debugButton.anchor(bottom: actionButtonStack.topAnchor, paddingBottom: 20)
}
```

# 参考
- [詳細! Swift 4 iPhoneアプリ開発 入門ノート Swift 4](www.amazon.co.jp/dp/4800711843)
	- ARの触りとして。解説が詳しくないので補足は必要。
- [iOS & Swift \- The Complete iOS App Development Bootcamp \| Udemy](https://www.udemy.com/course/ios-13-app-development-bootcamp/)のARパート
	- 平面検出やNodeの作成方法など、AR周りの基本を参照