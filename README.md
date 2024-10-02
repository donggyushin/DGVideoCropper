# DGVideoCropper
Simple and Clean Video Cropper made by SwiftUI. <br >
Available above iOS 16. 

https://github.com/user-attachments/assets/9acbd2e7-5a15-4298-96a4-dea1700b206c

## Installation

### Swift Package Manager

The [Swift Package Manager](https://www.swift.org/documentation/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding `DGVideoCropper` as a dependency is as easy as adding it to the dependencies value of your Package.swift or the Package list in Xcode.

```
dependencies: [
   .package(url: "https://github.com/donggyushin/DGVideoCropper", .upToNextMajor(from: "1.0.0"))
]
```

Normally you'll want to depend on the DGVideoCropper target:

```
.product(name: "DGVideoCropper", package: "DGVideoCropper")
```

## Usage

### Basic
```swift
import SwiftUI
import DGVideoCropper

struct ContentView: View {
    
    let model: DGCropModel = .init(url: {`valid file path url`} ) // if you input remote url, then fail to crop video.
    
    var body: some View {
        DGVideoCropper(model: model)
    }
}
```

### Crop Video
```swift
let croppedVideoFilePath = try await model.crop()
```

## Properties

All Properties are declared as @Published variables so that you can observe them.

| Property      | Type                     | Description                                                                                        |
|---------------|--------------------------|----------------------------------------------------------------------------------------------------|
| currentTime   | TimeInterval             | The current time of the video.                                                                     |
| duration      | TimeInterval             | Total play time of the video.                                                                      |
| percentage    | Double                   | currentTime / duration. Min value 0, Max value 1.                                                  |
| isPlaying     | Bool                     | Indicates the video is playing now.                                                                |
| startPosition | Double                   | Left handle bar's position percentage. Min value 0, Max value 1.                                   |
| endPosition   | Double                   | Right handle bar's position percentage. Min value 0, Max value 1.                                  |

## Functions

| Function                             | Description                                                                                                                                      |
|--------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| play()                               | Play the video. You can replace this model.                                                                                                      |
| pause()                              | Pause the video.                                                                                                                                 |
| crop()                               | If success, return cropped video's file path.                                                                                                    |
| moveLeftHandler(percentage: Double)  | You can adjust left handle bar. From 0 to 1.<br>Percentage should be range in (0~1) and smaller than right percentage. If not, it will not work. |
| moveRightHandler(percentage: Double) | You can adjust right handle bar. From 0 to 1.<br>Percentage should be range in (0~1) and bigger than left percentage. If not, it will not work.  |

