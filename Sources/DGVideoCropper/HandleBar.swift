//
//  File.swift
//  DGVideoCropper
//
//  Created by 신동규 on 9/12/24.
//

import SwiftUI

struct HandleBar: View {
    var body: some View {
        Rectangle()
            .fill(.white)
            .overlay {
                Rectangle()
                    .fill(.black)
                    .frame(width: 2, height: 15)
            }
            .clipShape(.rect(topLeadingRadius: 7, bottomLeadingRadius: 7))
            .frame(width: 15)
    }
}

#Preview {
    
    HandleBar()
        .frame(height: 50)
        .preferredColorScheme(.dark)
}
