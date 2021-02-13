//
//  ConfigureView.swift
//  Access
//
//  Created by Andreas on 2/12/21.
//


import SwiftUI
import RealityKit
import ARKit
import Vision
import AVFoundation

struct ConfigureView : View {
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
    @State var arView = ARViewContainer()
    
    @State var storedData = UserDefaults.standard
    @State var mapKey = "ar.worldmap"

    @State  var worldMapData: Data? = Data()
    
    
    var body: some View {
        
        VStack{
            arView.edgesIgnoringSafeArea(.all)
                .onAppear() {
                    arState.isConfigView = true
                    storedData.data(forKey: mapKey)
                    
                   }
            if !arState.isThumbnailHidden {
                if let image = arState.thumbnailImage {
                    SnapshotThumbnail(image: image)
                        .frame(width: 100, height: 200)
                        .aspectRatio(contentMode: .fit)
                        .padding(.leading, 10)
                }
            }
            HStack {
                SaveLoadBtn()
                Menu {
                                    
                    Button(action: {
                        directions.append("left")
                        addAudio = true
                    }) {
                        Text("Turn Left")
                    }
                    Button(action: {
                        directions.append("right")
                        addAudio = true
                    }) {
                        Text("Turn Right")
                    }
                    Button(action: {
                        directions.append("straight")
                        addAudio = true
                    }) {
                        Text("Continue Straight")
                    }
                    Button(action: {
                        directions.append("arrived")
                        addAudio = true
                    }) {
                        Text("You've arrived")
                    }
                                  }
                                  label: {
                                      Label("Place Audio", systemImage: "plus")
                                  }
          
            
            
            } .padding()
        }
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        
        
    }
    
}



