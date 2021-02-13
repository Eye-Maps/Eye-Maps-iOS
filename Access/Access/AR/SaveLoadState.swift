//
//  SaveLoadState.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import Foundation

final class SaveLoadState: ObservableObject {
    @Published var saveButton = ButtonState(isEnabled: true)
    @Published var loadButton = ButtonState(isHidden: true)
}
