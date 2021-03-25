//
//  CustomARView.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//

import SwiftUI
import RealityKit
import ARKit
import Vision
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
   

    let queue = DispatchQueue(label: "thread-safe-obj", attributes: .concurrent)
     lazy var classificationRequest: VNCoreMLRequest = {
      do {
        // 2
        let model = try VNCoreMLModel(for: Resnet50().model)
        // 3
        let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
           self?.processClassifications(for: request, error: error)
       })
       request.imageCropAndScaleOption = .centerCrop
           return request
      } catch {
        // 5
        fatalError("Failed to load Vision ML model: \(error)")
      }
    }()
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.vertical, .horizontal]
        configuration.environmentTexturing = .automatic

        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .meshWithClassification
            configuration.frameSemantics = .sceneDepth
            
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
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,  options: .duckOthers)
        } catch {
            
        }
        //self.debugOptions = [ .showFeaturePoints ]
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            camera.position = self.cameraTransform.translation
            
        
           
          
        }
    }
    
    // MARK: - AR content
    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"
    var virtualObject = CustomBox(color: .systemRed)
    
    
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
