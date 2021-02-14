//
//  Gestures.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI
import ARKit
import RealityKit

var placeIntitialAnchor = false
extension CustomARView {

    /// Add the tap gesture recogniser
    func setupGestures() {
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
      self.addGestureRecognizer(tap)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if addAudio {
                self.rayCastingMethod(point: self.center)
                addAudio = false
            }
            if placeIntitialAnchor {
                guard let raycastQuery = self.makeRaycastQuery(from: self.center,
                                                               allowing: .existingPlaneInfinite,
                                                               alignment: .horizontal) else {
                    
                    print("failed first")
                    placed = false
                    return
                }
                
                guard let result = self.session.raycast(raycastQuery).first else {
                    print("failed")
                    placed = false
                    return
                }
                
                // Remove exisitng anchor and add new anchor
              
                // Add ARAnchor into ARView.session, which can be persisted in WorldMap
                self.virtualObjectAnchor = ARAnchor(
                    name: self.virtualObjectAnchorName,
                        transform: result.worldTransform
                    )
                self.anchorz.append(self.virtualObjectAnchor!)
                self.session.add(anchor: self.virtualObjectAnchor!)
            
                placeIntitialAnchor = false
                placed = true
            }
        }
    }

    // MARK: - Placing AR Content
    
    func rayCastingMethod(point: CGPoint) {
        
        
        guard let raycastQuery = self.makeRaycastQuery(from: point,
                                                       allowing: .existingPlaneInfinite,
                                                       alignment: .horizontal) else {
            
            print("failed first")
            placed = false
            return
        }
        
        guard let result = self.session.raycast(raycastQuery).first else {
            print("failed")
            placed = false
            return
        }
      
            let transformation = Transform(matrix: result.worldTransform)
        if virtualObjectAnchor != nil {
            let distance = AnchorEntity(raycastResult: result).position(relativeTo: AnchorEntity(world: virtualObjectAnchor!.transform))
            distances.append(distance)
            transformations.append(transformation.translation)
           // print(distance)
            placed = true
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
         
           // Add ARAnchor into ARView.session, which can be persisted in WorldMap
               virtualObjectAnchor = ARAnchor(
               name: virtualObjectAnchorName,
                   transform: hitTestResult.worldTransform
               )
               anchorz.append(virtualObjectAnchor!)
           self.session.add(anchor: virtualObjectAnchor!)
       
          
       }
    
}
var i = 0
