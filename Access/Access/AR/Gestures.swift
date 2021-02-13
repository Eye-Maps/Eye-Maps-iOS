//
//  Gestures.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI
import ARKit
import RealityKit
extension CustomARView {

    /// Add the tap gesture recogniser
    func setupGestures() {
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
      //self.addGestureRecognizer(tap)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if addAudio {
                self.rayCastingMethod(point: self.center)
                addAudio = false
            }
        }
    }

    // MARK: - Placing AR Content
    
    func rayCastingMethod(point: CGPoint) {
        
        
        guard let raycastQuery = self.makeRaycastQuery(from: point,
                                                       allowing: .existingPlaneInfinite,
                                                       alignment: .horizontal) else {
            
            print("failed first")
            return
        }
        
        guard let result = self.session.raycast(raycastQuery).first else {
            print("failed")
            return
        }
        if i == 0 {
        self.session.add(anchor: ARAnchor(transform: result.worldTransform))
        
        } else {
            let transformation = Transform(matrix: result.worldTransform)
            let distance = AnchorEntity(raycastResult: result).position(relativeTo: AnchorEntity(world: virtualObjectAnchor!.transform))
            distances.append(distance)
            transformations.append(transformation)
            print(distance)
        }
        
        i += 1
        
    }
 

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // Disable placing objects when the session is still relocalizing
      
        // Hit test to find a place for a virtual object.
        guard let point = sender?.location(in: self),
              let hitTestResult = self.hitTest(
                point,
                types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane]
        ).last
        else { return }
        
        // Remove exisitng anchor and add new anchor
        if i != 0 {
            rayCastingMethod(point: point)
       
        
        } else {
        // Add ARAnchor into ARView.session, which can be persisted in WorldMap
            virtualObjectAnchor = ARAnchor(
            name: virtualObjectAnchorName,
                transform: hitTestResult.worldTransform
            )
            anchorz.append(virtualObjectAnchor!)
        self.session.add(anchor: virtualObjectAnchor!)
    }
        i += 1
    }
    
}
var i = 0
