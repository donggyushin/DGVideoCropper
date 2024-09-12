//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import AVFoundation

// 비디오를 크롭하는 함수 (async/await 사용)
func cropVideo(sourceURL: URL, start: Double, end: Double) async throws -> URL {
    // 원본 비디오 파일을 AVAsset으로 로드
    let asset = AVAsset(url: sourceURL)
    
    // 시작 시간과 종료 시간을 CMTime으로 변환
    let startTime = CMTime(seconds: start, preferredTimescale: 600)
    let endTime = CMTime(seconds: end, preferredTimescale: 600)
    let timeRange = CMTimeRange(start: startTime, end: endTime)
    
    // Export를 위한 AVAssetExportSession 생성
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
        throw NSError(domain: "ExportSessionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Export session could not be created"])
    }
    
    // 출력 파일의 임시 경로 지정
    let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("croppedVideo.mp4")
    
    // 이미 파일이 존재하면 제거
    try? FileManager.default.removeItem(at: outputURL)
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.timeRange = timeRange
    
    if #available(iOS 18.0, *) {
        try await exportSession.export(to: outputURL, as: .mp4)
        return outputURL
    } else {
        return try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                continuation.resume(returning: outputURL)
            }
        }
    }
}
