//
//  ARViewExtension.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import Foundation
import RealityKit
import ARKit
import AVFoundation

var entities = [Entity]()
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
            do {
               
                   try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .duckOthers)
                
            } catch {
                
            }
            anchorz.append(virtualObjectAnchor!)
            for i in distances.indices {
                let box = CustomBox(color: .cyan)
                
                box.transform = transformations[i]
                //box.position = (distances[i])
                anchorEntity.addChild(box)
                Access.entities.append(box)
                let audioSource = SCNAudioSource(fileNamed: "pulse.mp3")!
                audioSource.loops = false
                // Decode the audio from disk ahead of time to prevent a delay in playback
                audioSource.load()
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .duckOthers)
                } catch {
                    
                }
                
                let audioFilePath = "pulse.mp3"
                
                
                do {
                    let resource = try AudioFileResource.load(named: audioFilePath, in: nil, inputMode: .spatial, loadingStrategy: .preload, shouldLoop: true)
                    let audioController = box.prepareAudio(resource)
                    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                        if Access.entities.count > step {
                            if Access.entities[step].id == box.id {
                               
                    audioController.play()
                                   
                    }
                    }
                    }
                let timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    
                    let anchorPosition = box.transform.translation
                    let cameraPosition = camera.transform.translation
                    
                    // here’s a line connecting the two points, which might be useful for other things
                   
                    let distance = length(camera.position(relativeTo: box))
                    print(distance)
                    if distance < 0.3  {
                        if directions.count > step  {
                       // self.playSound(audioName: directions[step])
                        }
                         audioController.stop()
                        step += 1
                        
                    }
                }
                
                } catch {
                    
                }
            }
            self.scene.addAnchor(anchorEntity)
        } else {
            print("DEBUG: Unable to load modelEntity for \(virtualObject.name)")
        }
    }
    func playSound(audioName: String) {
         guard let url = Bundle.main.url(forResource: audioName, withExtension: "mp3") else { return }
        if !coolDown {
           
         do {
            
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .duckOthers)
               
            
          
             try AVAudioSession.sharedInstance().setActive(true)
         
         
             /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

             /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

             guard let player = player else { return }

             player.play()

           
            
         } catch let error {
             print(error.localizedDescription)
         }
           
            coolDown = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                coolDown = false
            }
            }
        
 }
}
    var step = 0
var coolDown = false
var player: AVAudioPlayer?
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
var coolDown2 = false
