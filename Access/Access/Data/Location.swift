//
//  Location.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI
import RealityKit

struct Location: Identifiable, Equatable, Codable {
    var id = UUID()
    var lat: Double
    var long: Double
    var title: String
    var subtitle: String
    var directions = [String]()
    var worldData = Data()
    var transformations = [SIMD3<Float>]()
    
}
