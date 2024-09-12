//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import SwiftUI

struct PlayBar: View {
    var body: some View {
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 6, height: 69)
          .background(.white)
          .cornerRadius(4)
          .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
}
