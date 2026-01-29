//
//  Model.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import AVKit
import Combine
import SwiftUI

@MainActor
public final class DGCropModel: ObservableObject {
    let avPlayer: AVPlayer
    let url: URL
    var timer: Timer?
    let maxTimeInterval: TimeInterval?
    var maxPositionDiff: Double = 1

    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var percentage: Double = 0
    @Published public var isPlaying: Bool = false
    @Published public var startPostion: Double = 0
    @Published public var endPosition: Double = 1

    @Published var imageFrames: [IdentifiableImage] = []

    private var cancellables = Set<AnyCancellable>()

    public init(url: URL, maxTimeInterval: TimeInterval? = nil) {
        self.avPlayer = .init(url: url)
        self.url = url
        self.maxTimeInterval = maxTimeInterval
        bind()
    }

    public func getDuration() async throws -> CGFloat {
        // AVAsset의 async load 메서드 사용
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)
        return seconds
    }

    public func configInitialEndPosition() {
        guard let maxTimeInterval else { return }
        guard maxTimeInterval < duration else { return }
        endPosition = maxTimeInterval / duration
        maxPositionDiff = endPosition - startPostion
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
        guard percentage <= endPosition, percentage >= startPostion else { return }

        currentTime = duration * percentage
        avPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1_000_000))
    }

    func dragHandleBar(percentage: Double, left: Bool) {
        guard percentage >= 0, percentage <= 1 else { return }
        if left {
            guard percentage < endPosition else { return }
            startPostion = percentage
        } else {
            guard percentage > startPostion else { return }
            endPosition = percentage
        }
        avPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1_000_000))

        let currentDiff = endPosition - startPostion
        if currentDiff > maxPositionDiff {
            let diff = currentDiff - maxPositionDiff

            if left == false {
                startPostion = startPostion + diff
            } else {
                endPosition = endPosition - diff
            }
        }
    }

    private func bind() {
        avPlayer
            .currentItem?
            .publisher(for: \.status)
            .filter { $0 == .readyToPlay }
            .combineLatest($duration)
            .filter { $0.1 > 0 }
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, duration in
                Task {
                    guard let images = try await self?.getImageFrames(duration: duration) else { return }
                    let identifiableImages = images.map { IdentifiableImage(image: $0) }
                    self?.imageFrames = identifiableImages
                }
            }
            .store(in: &cancellables)

        $duration
            .combineLatest($currentTime)
            .map { duration, currentTime in currentTime / duration }
            .assign(to: &$percentage)

        $startPostion
            .combineLatest($endPosition, $duration)
            .map { $0.0 * $0.2 }
            .assign(to: &$currentTime)

        $percentage
            .combineLatest($startPostion, $endPosition)
            .filter { percentage, start, end in percentage < start || percentage > end }
            .sink { [weak self] in self?.adjustCurrentTimeAndStopVideo(percentage: $0.0, start: $0.1, end: $0.2) }
            .store(in: &cancellables)
    }

    private func updateCurrentTime() {
        guard let currentTime = avPlayer.currentItem?.currentTime() else { return }
        self.currentTime = CMTimeGetSeconds(currentTime)
    }

    private func getImageFrames(duration: TimeInterval) async throws -> [Image] {
        let timeIntervals = DivideDurationUseCase(duration: duration, divide: 30)
            .execute()

        let asset: AVURLAsset = .init(url: url)

        var images: [Image] = []

        for timeInterval in timeIntervals {
            do {
                let image: Image = try await subtractImageFromVideo(asset, at: timeInterval)
                images.append(image)
            } catch {
                print("[DGVideoCropper] \(error)")
            }
        }

        return images
    }

    private func adjustCurrentTimeAndStopVideo(percentage: Double, start: Double, end: Double) {
        if percentage < start {
            let percentage = start
            let currentTime = duration * percentage
            self.currentTime = currentTime
            avPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1_000_000))
        } else if percentage > end {
            let percentage = end
            let currentTime = duration * percentage
            self.currentTime = currentTime
            avPlayer.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1_000_000))
        }
        avPlayer.pause()
    }
}

struct IdentifiableImage: Identifiable {
    let id: String = UUID().uuidString
    let image: Image
}
