//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import SwiftUI
import AVKit
import AVFoundation

func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
    let asset = AVURLAsset(url: url)

    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = .encodedPixels

    let cmTime = CMTime(seconds: time, preferredTimescale: 60)
    let thumbnailImageRef: CGImage
    do {
        thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
    } catch let error {
        print("Error: \(error)")
        return nil
    }

    return UIImage(cgImage: thumbnailImageRef)
}

func imageFromVideo(url: URL, at time: TimeInterval) -> Image? {
    guard let uiImage: UIImage = imageFromVideo(url: url, at: time) else { return nil }
    return .init(uiImage: uiImage)
}

