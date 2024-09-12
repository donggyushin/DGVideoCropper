//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import Foundation

final class DivideDurationUseCase {
    
    let duration: TimeInterval
    let divide: Int
    
    init(duration: TimeInterval, divide: Int) {
        self.duration = duration
        self.divide = divide
    }
    
    func execute() -> [TimeInterval] {
        var result: [TimeInterval] = []
        
        let diff: TimeInterval = duration / TimeInterval(divide)
        var value: TimeInterval = 0
        
        while value <= duration {
            result.append(value)
            value += diff
        }
        
        return result
    }
}
