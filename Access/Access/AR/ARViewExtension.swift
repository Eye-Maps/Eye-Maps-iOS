//
//  ARViewExtension.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import SwiftUI
import ARKit
import RealityKit

var step = 0
var entities = [Entity]()
let camera = Entity()
var coolDown = false
var player: AVAudioPlayer?
extension CustomARView {
    
    
     
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if addAudio {
                self.rayCastingMethod(point: self.center)
                addAudio = false
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        guard let touchInView = sender?.location(in: self) else {
            return
        }
        
        
        let entities = self.entities(at: touchInView)
        
    }
    
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
        
        let transformation = Transform(matrix: result.worldTransform)
        let greenBox = CustomBox(color: .yellow)
        self.installGestures(.all, for: greenBox)
        greenBox.generateCollisionShapes(recursive: true)
        
        let mesh = MeshResource.generateText(
            "",
            extrusionDepth: 0.1,
            font: .systemFont(ofSize: 2),
            containerFrame: .zero,
            alignment: .left,
            lineBreakMode: .byTruncatingTail)
        
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.scale = SIMD3<Float>(0.03, 0.03, 0.1)
        Access.entities.append(entity)
        greenBox.addChild(entity)
        greenBox.transform = transformation
        //setting relative position...
        entity.setPosition(SIMD3<Float>(0, 0.05, 0), relativeTo: greenBox)
        let audioSource = SCNAudioSource(fileNamed: "pulse.mp3")!
        audioSource.loops = true
        // Decode the audio from disk ahead of time to prevent a delay in playback
        audioSource.load()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .duckOthers)
        } catch {
            
        }
        let raycastAnchor = AnchorEntity(raycastResult: result)
        let audioFilePath = "pulse.mp3"
        raycastAnchor.addChild(greenBox)
        
        do {
            let resource = try AudioFileResource.load(named: audioFilePath, in: nil, inputMode: .spatial, loadingStrategy: .preload, shouldLoop: true)
            let audioController = entity.prepareAudio(resource)
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if Access.entities.count > step {
            if Access.entities[step] == entity {
           
            audioController.play()
            }
            }
            }
            // If you want to start playing right away, you can replace lines 7-8 with line 11 below
            // let audioController = entity.playAudio(resource)
            raycastAnchor.addChild(entity)
            
            let timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                
                let anchorPosition = entity.transform.translation
                let cameraPosition = camera.transform.translation
                
                // here’s a line connecting the two points, which might be useful for other things
               
                let distance = length(camera.position(relativeTo: entity))
                print(distance)
                if distance < 10  {
                     audioController.stop()
                    step += 1
                }
            }
        } catch {
            print("Error loading audio file")
        }
        
        
        // here’s a line connecting the two points, which might be useful for other things
        
        self.scene.addAnchor(raycastAnchor)
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
extension ARView: ARSessionDelegate {
    public func session(_ session: ARSession,
                        didUpdate frame: ARFrame) {
        
    }
}
extension ARView: ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let utterance = AVSpeechUtterance(string: "Move your device in a brightly lit area until I say stop")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        //synthesizer.speak(utterance)
        coachingOverlay.goal = .anyPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = false
        //Ready to add objects
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .duckOthers)
        } catch {
            
        }
        let utterance = AVSpeechUtterance(string: "You can place audio now")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        // ready = true
    }
    
}
