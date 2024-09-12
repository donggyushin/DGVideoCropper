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
    let avPlayer: AVPlayer
    let url: URL
    var timer: Timer?
    
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var percentage: Double = 0
    @Published public var isPlaying: Bool = false
    @Published public var startPostion: Double = 0
    @Published public var endPosition: Double = 1
    
    @Published var imageFrames: [IdentifiableImage] = []
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    public func moveLeftHandleBar(percentage: Double) {
        dragHandleBar(percentage: percentage, left: true)
    }
    
    public func moveRightHandleBar(percentage: Double) {
        dragHandleBar(percentage: percentage, left: false)
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
        guard percentage >= 0 && percentage <= 1 else { return }
        if left {
            guard percentage < endPosition else { return }
            self.startPostion = percentage
        } else {
            guard percentage > startPostion else { return }
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
        
        $percentage
            .combineLatest($startPostion, $endPosition)
            .filter({ percentage, start, end in (percentage < start || percentage > end) })
            .sink { [weak self] in self?.adjustCurrentTimeAndStopVideo(percentage: $0.0, start: $0.1, end: $0.2) }
            .store(in: &cancellables)
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
    
    private func adjustCurrentTimeAndStopVideo(percentage: Double, start: Double, end: Double) {
        if percentage < start {
            let percentage = start
            let currentTime = duration * percentage
            self.currentTime = currentTime
            avPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1000000))
        } else if percentage > end {
            let percentage = end
            let currentTime = duration * percentage
            self.currentTime = currentTime
            avPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1000000))
        }
    }
}

struct IdentifiableImage: Identifiable {
    let id: String = UUID().uuidString
    let image: Image
}
