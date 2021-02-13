//
//  SnapshotThumbnail.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import UIKit
import SwiftUI

struct SnapshotThumbnail: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .background(Color.gray.opacity(0.5))
            .cornerRadius(12)
    }
}

