//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import AVKit
import UIKit
import Combine

final class VideoViewerUIKit: UIView {
    
    let player: AVPlayer
    
    private var viewSetup: Bool = false
    
    init(player: AVPlayer) {
        self.player = player
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView(avPlayer: player)
    }
    
    private func setupView(avPlayer: AVPlayer) {
        guard bounds != .zero else { return }
        guard viewSetup == false else { return }
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        
        let playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        viewSetup = true
    }
}

