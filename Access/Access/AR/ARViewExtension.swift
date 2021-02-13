//
//  ARViewExtension.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import Foundation
import RealityKit
import ARKit

extension CustomARView {
    
  
    
    func addAnchorEntityToScene(anchor: ARAnchor) {
        guard anchor.name == virtualObjectAnchorName else {
            return
        }
        // save the reference to the virtual object anchor when the anchor is added from relocalizing
        if virtualObjectAnchor == nil {
            virtualObjectAnchor = anchor
        }
        
        if let modelEntity = virtualObject.modelEntity {
            print("DEBUG: adding model to scene - \(virtualObject.name)")
            
            // Add modelEntity and anchorEntity into the scene for rendering
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(modelEntity)
            anchorz.append(virtualObjectAnchor!)
            for i in distances.indices {
                let box = CustomBox(color: .cyan)
                
                box.transform = transformations[i]
                //box.position = (distances[i])
                anchorEntity.addChild(box)
                
            }
            self.scene.addAnchor(anchorEntity)
        } else {
            print("DEBUG: Unable to load modelEntity for \(virtualObject.name)")
        }
    }
    
}

extension CustomARView: ARSessionDelegate {
    
    // MARK: - AR session delegate
  
    // This is where we render virtual contents to scene.
    // We add an anchor in `handleTap` function, it will then call this function.
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("did add anchor: \(anchors.count) anchors in total")
        
        for anchor in anchors {
            addAnchorEntityToScene(anchor: anchor)
        }
    }
}
