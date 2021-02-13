//
//  Location.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI

struct Location: Identifiable, Codable {
    var id = UUID()
    var lat: Double
    var long: Double
    var title: String
    var subtitle: String
}
