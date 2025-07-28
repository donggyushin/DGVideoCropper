//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import SwiftUI
import AVKit
import AVFoundation

public func subtractImageFromVideo(_ asset: AVURLAsset, at time: TimeInterval) async throws -> UIImage {
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = .encodedPixels
    assetIG.requestedTimeToleranceBefore = .zero
    assetIG.requestedTimeToleranceAfter = .zero
    
    let cmTime = CMTime(seconds: time, preferredTimescale: 600)
    
    let image = try await assetIG.image(at: cmTime)
    
    return UIImage(cgImage: image.image)
}

public func subtractImageFromVideo(_ asset: AVURLAsset, at time: TimeInterval) async throws -> Image {
    let image: UIImage = try await subtractImageFromVideo(asset, at: time)
    return .init(uiImage: image)
}
