//
//  ARState.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import Foundation
import SwiftUI

final class ARState: ObservableObject {
    @Published var sessionInfoLabel = "Initializing"
    @Published var isThumbnailHidden = true
    @Published var thumbnailImage: UIImage?
    @Published var mappingStatus = "Mapping: "
    @Published var resetButton = ButtonState()
}
