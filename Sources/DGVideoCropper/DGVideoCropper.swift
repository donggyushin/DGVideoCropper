// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct DGVideoCropper: View {
    
    @StateObject var model: DGCropModel
    
    public init(model: DGCropModel) {
        _model = .init(wrappedValue: model)
    }
    
    public var body: some View {
        VStack(spacing: 25) {
            VideoViewerUIKitContainer(player: model.avPlayer)
                .clipShape(RoundedRectangle(cornerRadius: 17))
                .onTapGesture {
                    model.tapVideo()
                }
                .padding(.horizontal, 5)
            
            ZStack {
                HStack(spacing:0) {
                    ForEach(model.imageFrames) { image in
                        image.image
                            .resizable()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.clear)
                        .overlay(alignment: .top) {
                            HStack {
                                Spacer(minLength: geo.size.width * model.startPostion)
                                Rectangle()
                                Spacer(minLength: geo.size.width * (1 - model.endPosition))
                            }
                            .frame(height: 3)
                        }
                        .overlay(alignment: .bottom) {
                            HStack {
                                Spacer(minLength: geo.size.width * model.startPostion)
                                Rectangle()
                                Spacer(minLength: geo.size.width * (1 - model.endPosition))
                            }
                            .frame(height: 3)
                        }
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.black.opacity(0.4))
                                .frame(width: geo.size.width * model.startPostion)
                                .offset(x: -15)
                        }
                        .overlay(alignment: .trailing) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.black.opacity(0.4))
                                .frame(width: geo.size.width * (1 - model.endPosition))
                        }
                        .overlay(alignment: .leading) {
                            HandleBar()
                                .offset(x: geo.size.width * model.startPostion - 15)
                                .gesture(handleBarDragGesture(fullWidth: geo.size.width, left: true))
                        }
                        .overlay(alignment: .leading) {
                            HandleBar()
                                .rotationEffect(.degrees(180))
                                .offset(x: geo.size.width * model.endPosition)
                                .gesture(handleBarDragGesture(fullWidth: geo.size.width, left: false))
                        }
                        .overlay(alignment: .leading) {
                            PlayBar()
                                .offset(x: geo.size.width * model.percentage)
                                .gesture(playBarDragGesture(fullWidth: geo.size.width))
                        }
                }
                .padding(.horizontal, 15)
                
            }
            .frame(height: 57)
        }
    }
    
    @State private var shouldPlayVideo: Bool = false
    @State private var previousPercentage: Double = 0
    @State private var gestureStarted: Bool = false
    private func playBarDragGesture(fullWidth: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if model.isPlaying && shouldPlayVideo == false {
                    shouldPlayVideo = true
                    model.pause()
                }
                if gestureStarted == false {
                    gestureStarted = true
                    previousPercentage = model.percentage
                }
                let width = value.translation.width
                var newPercentage = width / (fullWidth)
                newPercentage += previousPercentage
                newPercentage = min(newPercentage, 1)
                newPercentage = max(0, newPercentage)
                model.dragPlayBar(percentage: newPercentage)
            }
            .onEnded { _ in
                if shouldPlayVideo {
                    model.play()
                    shouldPlayVideo = false
                }
                gestureStarted = false
            }
    }
    
    private func handleBarDragGesture(fullWidth: CGFloat, left: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if model.isPlaying && shouldPlayVideo == false {
                    shouldPlayVideo = true
                    model.pause()
                }
                if gestureStarted == false {
                    gestureStarted = true
                    if left {
                        previousPercentage = model.startPostion
                    } else {
                        previousPercentage = model.endPosition
                    }
                }
                let width = value.translation.width
                var newPercentage = width / (fullWidth)
                newPercentage += previousPercentage
                if left {
                    newPercentage = min(newPercentage, model.endPosition)
                    newPercentage = max(0, newPercentage)
                } else {
                    newPercentage = min(1, newPercentage)
                    newPercentage = max(model.startPostion, newPercentage)
                }
                model.dragHandleBar(percentage: newPercentage, left: left)
            }
            .onEnded { _ in
                if shouldPlayVideo {
                    model.play()
                    shouldPlayVideo = false
                }
                gestureStarted = false
            }
    }
}