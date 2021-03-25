//
//  ContentView.swift
//  Access
//
//  Created by Andreas on 2/6/21.
//
import SwiftUI
import RealityKit
import ARKit
import Vision
import AVFoundation
import FirebaseStorage
var addAudio = false
var directions = [String]()
var placed = false
struct ContentView : View {
    
    @EnvironmentObject var saveLoadState: SaveLoadState
    @EnvironmentObject var arState: ARState
    @State var mapDataFromFile: Data? = Data()

    @State var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }()
   
    
    @State var storedData = UserDefaults.standard
    @State var mapKey = "ar.worldmap"
    @Binding var location: Location
    @State  var worldMapData: Data? = Data()
    @State var showInitial = true
    @State var distance = 0.0
    @State var classify = "x"
    var body: some View {
        ZStack {
            
            Color.clear
                .onDisappear() {
                    directions = []
                    worldMapData = Data()
                    transformations = []
                    placeIntitialAnchor = false
                    saveLoadState.loadButton.isHidden = true
                    
                }
                .onAppear() {
                    //saveLoadState.loadButton.isEnabled = true
                    //saveLoadState.loadButton.isHidden = false
                    directions = location.directions
                    
                    for i in location.transformationsX.indices {
                        transformations.append(SIMD3<Float>(location.transformationsX[i], location.transformationsY[i], location.transformationsZ[i]))
                    }
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                        location.directions = directions
                        location.worldData = worldMapData ?? Data()
                        location.transformationsX = []
                        location.transformationsY = []
                        location.transformationsZ = []
                        for transform in transformations {
                            location.transformationsX.append(transform.x)
                            location.transformationsY.append(transform.y)
                            location.transformationsZ.append(transform.z)
                        }
                        if placed {
                            showInitial = false
                        } else {
                            showInitial = true
                        }
                        
                    }
                }
        VStack {
            Text("\(distance) meters")
                .font(.headline)
                .onChange(of: meters, perform: { value in
                    distance = meters
                })
            Text("\(classify)")
                .font(.headline)
              
                .onChange(of: classification, perform: { value in
                    classify = classification
                })
            
            ARViewContainer(saveLoadState: _saveLoadState, location: $location).edgesIgnoringSafeArea(.all)
                .onAppear() {
                    storedData.data(forKey: mapKey)
                   }
               
            HStack {
                SaveLoadBtn()
                   
                if showInitial {
                Button(action: {
                    placeIntitialAnchor = true
                }) {
                    Text("Place Initial Anchor")
                        .multilineTextAlignment(.center)
                }  .accessibility(label: Text("Place Initial Anchor"))
                }
                Menu {
                                    
                    Button(action: {
                        location.directions.append("left")
                        directions.append("left")
                        addAudio = true
                    }) {
                        Text("Turn Left")
                    }
                    Button(action: {
                        location.directions.append("right")
                        directions.append("right")
                        addAudio = true
                    }) {
                        Text("Turn Right")
                    }
                    Button(action: {
                        location.directions.append("straight")
                        directions.append("straight")
                        addAudio = true
                    }) {
                        Text("Continue Straight")
                    }
                    Button(action: {
                        location.directions.append("arrived")
                        directions.append("arrived")
                        addAudio = true
                    }) {
                        Text("You've arrived")
                    }
                    Button(action: {
                        location.directions.append("door")
                        directions.append("door")
                        addAudio = true
                    }) {
                        Text("Door Ahead")
                    }
                    Button(action: {
                        location.directions.append("steps")
                        directions.append("steps")
                        addAudio = true
                    }) {
                        Text("Steps Ahead")
                    }
                   
                                  }
                                  label: {
                                      Label("Place Audio", systemImage: "plus")
                                  }
            
            
            } .padding()
            
        }
    }
    }
    
    
}



class CustomBox: Entity, HasModel, HasAnchoring, HasCollision {
    
    required init(color: UIColor) {
        super.init()
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateBox(size: 0.1),
            materials: [SimpleMaterial(
                            color: color,
                            isMetallic: false)
            ]
        )
    }
    
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}



struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var saveLoadState: SaveLoadState
    @EnvironmentObject var arState: ARState
    @Binding var location: Location
    func makeUIView(context: Context) -> CustomARView {
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Pass in @EnvironmentObject
        let arView = CustomARView(frame: .zero, saveLoadState: saveLoadState, arState: arState, location: location)
        
        // Read in any already saved map to see if we can load one.
        if arView.worldMapData != nil {
            saveLoadState.loadButton.isHidden = false
        }
        
        arView.setup()

        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
        
        if saveLoadState.saveButton.isPressed {
            uiView.saveExperience()
            
            DispatchQueue.main.async {
                self.saveLoadState.saveButton.isPressed = false
            }
        }
        
        if saveLoadState.loadButton.isPressed {
            uiView.loadExperience()
            self.saveLoadState.loadButton.isPressed = false
            // Note: If we reset isPressed to false in main.async, it will crash
            // DispatchQueue.main.async {
            //      self.saveLoadData.loadButton.isPressed = false
            // }
        }
        
        if arState.resetButton.isPressed {
            uiView.resetTracking()
            
            DispatchQueue.main.async {
                self.arState.resetButton.isPressed = false
            }
        }
    }

}
var meters = 0.0
var classification = "None"
