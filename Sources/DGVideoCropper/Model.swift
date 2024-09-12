//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import Combine
import AVKit
import SwiftUI

@MainActor
public final class DGCropModel: ObservableObject {
    public let avPlayer: AVPlayer
    public let url: URL
    
    var timer: Timer?
    
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var percentage: Double = 0
    @Published public var isPlaying: Bool = false
    @Published public var startPostion: Double = 0
    @Published public var endPosition: Double = 1
    
    @Published var imageFrames: [IdentifiableImage] = []
    
    public init(url: URL) {
        avPlayer = .init(url: url)
        self.url = url
        bind()
    }
    
    public func play() {
        isPlaying = true
        avPlayer.play()
        timer = .scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task {
                await self?.updateCurrentTime()
            }
        }
    }
    
    public func pause() {
        isPlaying = false
        avPlayer.pause()
        timer?.invalidate()
    }
    
    public func crop() async throws -> URL {
        let start = duration * startPostion
        let end = duration * endPosition
        
        return try await cropVideo(sourceURL: url, start: start, end: end)
    }
    
    func tapVideo() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func dragPlayBar(percentage: Double) {
        self.currentTime = duration * percentage
        avPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1000000))
    }
    
    func dragHandleBar(percentage: Double, left: Bool) {
        if left {
            self.startPostion = percentage
        } else {
            self.endPosition = percentage
        }
        avPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1000000))
    }
    
    private func bind() {
        avPlayer
            .currentItem?
            .publisher(for: \.duration)
            .filter({ !CMTIME_IS_INDEFINITE($0) })
            .removeDuplicates()
            .map({ CMTimeGetSeconds($0) })
            .assign(to: &$duration)
        
        avPlayer
            .currentItem?
            .publisher(for: \.status)
            .filter({ $0 == .readyToPlay })
            .combineLatest($duration)
            .filter({ $0.1 > 0 })
            .first()
            .compactMap({ [weak self] in self?.getImageFrames(duration: $0.1) })
            .map({ $0.map({ IdentifiableImage(image: $0) }) })
            .assign(to: &$imageFrames)
            
        $duration
            .combineLatest($currentTime)
            .map({ duration, currentTime in currentTime / duration })
            .assign(to: &$percentage)
        
        $startPostion
            .combineLatest($endPosition, $duration)
            .map({ $0.0 * $0.2 })
            .assign(to: &$currentTime)
    }
    
    private func updateCurrentTime() {
        guard let currentTime = avPlayer.currentItem?.currentTime() else { return }
        self.currentTime = CMTimeGetSeconds(currentTime)
    }
    
    private func getImageFrames(duration: TimeInterval) -> [Image] {
        DivideDurationUseCase(duration: duration, divide: 30)
            .execute()
            .compactMap({ imageFromVideo(url: url, at: $0) })
    }
}

struct IdentifiableImage: Identifiable {
    let id: String = UUID().uuidString
    let image: Image
}
