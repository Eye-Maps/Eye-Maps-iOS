//
//  CustomARView.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import SwiftUI
import RealityKit
import ARKit

var transformations = [SIMD3<Float>]()
var camera = Entity()
class CustomARView: ARView {
    enum FocusStyleChoices {
      case classic
      case material
      case color
    }
    var location: Location
    // Referring to @EnvironmentObject
    let focusStyle: FocusStyleChoices = .classic
    var focusEntity: FocusEntity?
    var saveLoadState: SaveLoadState
    var arState: ARState
    var distances = [SIMD3<Float>]()
    var anchorz = [ARAnchor]()
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        return configuration
    }
    // MARK: - Init and setup
    
    init(frame frameRect: CGRect, saveLoadState: SaveLoadState, arState: ARState, location: Location) {
        self.saveLoadState = saveLoadState
        self.arState = arState
        self.location = location
        super.init(frame: frameRect)
        switch self.focusStyle {
        case .color:
          self.focusEntity = FocusEntity(on: self, focus: .plane)
        case .material:
          do {
            let onColor: MaterialColorParameter = try .texture(.load(named: "Add"))
            let offColor: MaterialColorParameter = try .texture(.load(named: "Open"))
            self.focusEntity = FocusEntity(
              on: self,
              style: .colored(
                onColor: onColor, offColor: offColor,
                nonTrackingColor: offColor
              )
            )
          } catch {
            self.focusEntity = FocusEntity(on: self, focus: .classic)
            print("Unable to load plane textures")
            print(error.localizedDescription)
          }
        default:
          self.focusEntity = FocusEntity(on: self, focus: .classic)
        }
    }

    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    func setup() {
        self.session.run(defaultConfiguration)
        self.session.delegate = self
        self.setupGestures()
        //self.debugOptions = [ .showFeaturePoints ]
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            camera.position = self.cameraTransform.translation
            
            let distance = length(self.focusEntity!.position(relativeTo: camera))
           // print(distance)
            if distance < 0.5 {
                if !coolDown3 {
                let utterance = AVSpeechUtterance(string: "Wall ahead")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                utterance.rate = 0.5

                let synthesizer = AVSpeechSynthesizer()
               // synthesizer.speak(utterance)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        coolDown3 = false
                    }
            }
            }
        }
    }
    
    // MARK: - AR content
    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"
    var virtualObject = AssetModel(name: "teapot.usdz")
    
    
    // MARK: - AR session management
    var isRelocalizingMap = false
    
 
    // MARK: - Persistence: Saving and Loading
    let storedData = UserDefaults.standard
    

    lazy var worldMapData: Data? = {
        storedData.data(forKey: location.id.uuidString)
    }()
    
    func resetTracking() {
        self.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        self.isRelocalizingMap = false
        self.virtualObjectAnchor = nil
    }
}
var coolDown3 = false
