//
//  SaveLoadBtn.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import SwiftUI

struct SaveLoadBtn: View {
    @EnvironmentObject var saveLoadState: SaveLoadState
    @EnvironmentObject var arState: ARState
    var body: some View {
        HStack {
            // Load Button
            if !saveLoadState.loadButton.isHidden {
                Button(action: {
                    print("DEBUG: Load ARWorld map.")
                    arState.isThumbnailHidden = false
                    saveLoadState.loadButton.isPressed = true
                }) {
                    Text("Load Experience")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .background(Color.blue)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .cornerRadius(8)
                //.disabled(!saveLoadState.loadButton.isEnabled)
            }
            
            // Save Button
            Button(action: {
                print("DEBUG: Save ARWorld map.")
                
                saveLoadState.saveButton.isPressed = true
            }) {
                Text("Save Experience")
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                
            }
            .background(saveLoadState.saveButton.isEnabled ? Color.blue : Color.gray)
            .font(.system(size: 15))
            .foregroundColor(.white)
            .cornerRadius(8)
            //.disabled(!saveLoadState.saveButton.isEnabled)
        }
    }
}
