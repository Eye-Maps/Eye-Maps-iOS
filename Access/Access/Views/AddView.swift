//
//  AddView.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
struct AddView: View {
    @Binding var locations: [Location]
    @State var location =  Location(id: UUID(), lat: 0.0, long: 0.0, title: "", subtitle: "", directions: [String](), worldData: Data(), transformationsX: [Float](), transformationsY: [Float](), transformationsZ: [Float](), location: GeoPoint(latitude: 0.0, longitude: 0.0))
    @State var next = false
    @EnvironmentObject var saveLoadState: SaveLoadState
    @ObservedObject var locationManager = LocationManager()
    @EnvironmentObject var arState: ARState
    var userLatitude: Double {
        return locationManager.lastLocation?.coordinate.latitude ?? 0
    }

    var userLongitude: Double {
        return locationManager.lastLocation?.coordinate.longitude ?? 0
    }
    @State var isPublic = true
    var body: some View {
        ZStack {
        VStack {
        HStack {
        Text("General Location of Map")
            .font(.title)
            Spacer()
        } .padding()
        TextField("General Location", text: $location.title)
            .padding()
        HStack {
        Text("Specific Location of Map")
            .font(.title)
            Spacer()
        } .padding()
        TextField("Specific Location", text: $location.subtitle)
            .padding()
         
            Toggle(isOn: $isPublic) {
                Text("Make this map public")
                    .font(.headline)
            } .padding()
            Spacer()
            Button(action: {
                if isPublic {
                location.lat = userLatitude
                location.long = userLongitude
                location.location = GeoPoint(latitude: userLatitude, longitude: userLongitude)
                }
                locations.append(location)
                
                
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 25.0).foregroundColor(.blue)
                        .padding()
                        .frame(height: 85)
                    Text("Begin Mapping")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .onChange(of: locations, perform: { value in
                
            
                next = true
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(locations) {
                    if let json = String(data: encoded, encoding: .utf8) {
                      //  print(json)
                        do {
                            var url = self.getDocumentsDirectory().appendingPathComponent("locations.txt")
                           
                            try json.write(to: url, atomically: true, encoding: String.Encoding.utf8)
                        
                        } catch {
                            print("erorr")
                        }
                        }

                   
                }
              
    })
            }
            if next {
                ZStack {
                Color.white
                    if !locations.isEmpty {
                    ContentView(location: $locations[locations.count - 1])
                        .environmentObject(self.saveLoadState)
                        .environmentObject(self.arState)
                        .onDisappear {
                            if isPublic {
                            let db = Firestore.firestore()
                               
                                do{
                                    try db.collection("locations").document(location.id.uuidString).setData(from: locations[locations.count - 1])
                                   
                                   
                                } catch {
                                    
                                }
                            }
                }
                    } else {
                        ContentView(location: $locations[locations.count])
                            .environmentObject(self.saveLoadState)
                            .environmentObject(self.arState)
                            .onDisappear {
                                if isPublic {
                                let db = Firestore.firestore()
                                   
                                    do{
                                        try db.collection("locations").document(location.id.uuidString).setData(from: locations[locations.count])
                                        let storage = Storage.storage()
                                        let storageRef = storage.reference()
                                        
                                        let riversRef = storageRef.child("\(location.id).data")

                                        // Upload the file to the path "images/rivers.jpg"
                                        riversRef.putData(locations[locations.count].worldData, metadata: .none)
                                  
                                    } catch {
                                        
                                    }
                                }
                    }
                    }
        }
            }
        }
    
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}


