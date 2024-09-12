//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import SwiftUI
import AVKit

struct VideoViewerUIKitContainer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> VideoViewerUIKit {
        VideoViewerUIKit(player: player)
    }
    
    func updateUIView(_ uiView: VideoViewerUIKit, context: Context) {
        // Updates the state of the specified view with new information from SwiftUI.
    }
}

