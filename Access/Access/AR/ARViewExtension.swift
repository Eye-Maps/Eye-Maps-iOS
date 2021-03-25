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
        
         let modelEntity = virtualObject
            print("DEBUG: adding model to scene - \(virtualObject.name)")
            
            // Add modelEntity and anchorEntity into the scene for rendering
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(modelEntity)
        modelEntity.transform.translation = anchor.transform.translation
            do {
               
                   try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .duckOthers)
                
            } catch {
                
            }
            anchorz.append(virtualObjectAnchor!)
            for i2 in transformations.indices {
                var stop = false
                let box = CustomBox(color: .cyan)
                var played = false
                box.transform.translation = transformations[i2]
                //box.position = (distances[i])
                anchorEntity.addChild(box)
                Access.entities.append(box)
                let audioSource = SCNAudioSource(fileNamed: "002.mp3")!
                audioSource.loops = false
               
                // Decode the audio from disk ahead of time to prevent a delay in playback
                audioSource.load()
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .duckOthers)
                } catch {
                    
                }
                
                let audioFilePath = "002.mp3"
                
                
                do {
                    let resource = try AudioFileResource.load(named: audioFilePath, in: nil, inputMode: .spatial, loadingStrategy: .preload, shouldLoop: true)
                    let audioController = box.prepareAudio(resource)
                    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                       
                        if Access.entities.count > step {
                                    if Access.entities[step] == box {
                                print(i2)
                                        audioController.play()
                                                        timer.invalidate()
                               
                            } else {
                                //audioController.pause()
                            }
                        }
                    }
                let timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    
                    let anchorPosition = box.transform.translation
                    let cameraPosition = camera.transform.translation
                    
                    // here’s a line connecting the two points, which might be useful for other things
                   
                    let distance = length(camera.position(relativeTo: box))
                  //  print(distance)
                    if distance < 1.1  {
                        if self.location.directions.count > step  {
                      //  self.playSound(audioName: directions[step])
                        }
                        stop = true
                        audioController.stop()
                        if !coolDown {
                            
                          coolDown = true
                            step += 1
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            coolDown = false
                        }
                        }
                        
                       
                        
                    }
                }
                
                } catch {
                    
                }
            }
            self.scene.addAnchor(anchorEntity)
        
    }
    func playSound(audioName: String) {
         guard let url = Bundle.main.url(forResource: audioName, withExtension: "mp3") else { return }
        if !coolDown {
           
         do {
            
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .mixWithOthers)
               
            
          
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
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
      
        DispatchQueue.global(qos: .userInitiated).async {
        //queue.async(flags: .barrier) {
            let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: .up)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
        
        //let depthData = frame.sceneDepth?.depthMap
        let depthDataMap = frame.sceneDepth?.depthMap
           //## Data Analysis ##

           // Useful data
        if depthDataMap != nil {
        let width = CVPixelBufferGetWidth(depthDataMap!) //768 on an iPhone 7+
        let height = CVPixelBufferGetHeight(depthDataMap!) //576 on an iPhone 7+
        CVPixelBufferLockBaseAddress(depthDataMap!, CVPixelBufferLockFlags(rawValue: 0))

           // Convert the base address to a safe pointer of the appropriate type
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthDataMap!), to: UnsafeMutablePointer<Float32>.self)

           // Read the data (returns value of type Float)
           // Accessible values : (width-1) * (height-1) = 767 * 575

           let distanceAtXYPoint = floatBuffer[Int(767 * 575)]
        print(distanceAtXYPoint)
            meters = Double(distanceAtXYPoint)
        }
    }
   

    // write
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                //print("Unable to classify image.\n\(error!.localizedDescription)")
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            if !classifications.isEmpty {
               
               // if classifications.last!.confidence > 0.2 {
                    print(classifications.first!.identifier)
                    classification = classifications.last!.identifier
            //}
            }
}
    }
}
var coolDown2 = false

