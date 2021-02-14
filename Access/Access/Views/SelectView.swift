//
//  SelectView.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
struct SelectView: View {
    @State var locations = [Location]()
    @State var open = false
    @State var add = false
    @State var config = false
    @State var i3 = 0
    @State var ready = false
    @ObservedObject var locationManager = LocationManager()
    @EnvironmentObject var saveLoadState: SaveLoadState
    @EnvironmentObject var arState: ARState
    let storedData = UserDefaults.standard
        var userLatitude: Double {
            return locationManager.lastLocation?.coordinate.latitude ?? 0
        }

        var userLongitude: Double {
            return locationManager.lastLocation?.coordinate.longitude ?? 0
        }
    var body: some View {
        ZStack {
            Color.clear
                .onAppear() {
                   
                    let url = self.getDocumentsDirectory().appendingPathComponent("locations.txt")
                    do {
                       
                        let input = try String(contentsOf: url)
                        
                       
                        let jsonData = Data(input.utf8)
                        do {
                            let decoder = JSONDecoder()

                            do {
                                let notes = try decoder.decode([Location].self, from: jsonData)
                               
                               locations = notes
                                 
                               
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                    } catch {
                        print(error.localizedDescription)
                        
                    }
                } catch {
                    print(error.localizedDescription)
                    
                }
                
                    self.loadNearby() { userData in
                        //Get completion handler data results from loadData function and set it as the recentPeople local variable
                        for data in userData {
                            self.locations.append(data)
                        }
                        locations = locations.removeDuplicates()
                    }
                    ready = true
                    }
            if ready {
                ScrollView {
            VStack {
        HStack {
            Spacer()
            Button(action: {
                add = true
                open = true
            }) {
            Image(systemName: "plus")
                .font(.title)
                .foregroundColor(.blue)
        } .accessibility(label: Text("Add Locations"))
            
            
        } .padding()
        ForEach(locations.indices, id: \.self) { i in
            Button(action: {
                config = true
                open = true
                self.i3 = i
            }) {
            LocationView(location: $locations[i], open: $open, config: $config)
                .padding()
                .accessibility(label: Text("\(locations[i].title) and \(locations[i].subtitle)"))
            }
        }
        .onDisappear() {
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(locations) {
            if let json = String(data: encoded, encoding: .utf8) {
                //print(json)
                do {
                    var url = self.getDocumentsDirectory().appendingPathComponent("locations.txt")
                   
                    try json.write(to: url, atomically: true, encoding: String.Encoding.utf8)
                
                } catch {
                    print("erorr")
                }
                }

           
        }
       
    }
       
        Spacer()
            .sheet(isPresented: $open) {
                ZStack {
                if add {
                   AddView(locations: $locations)
                    .environmentObject(self.saveLoadState)
                    .environmentObject(self.arState)
                  
                }
                if config {
                    ContentView(location: $locations[i3])
                        .environmentObject(self.saveLoadState)
                        .environmentObject(self.arState)
                       
                }
            }  .onDisappear() {
                add = false
                config = false
                
            }
       }
            }
            }
    }
        }
    }
    func loadNearby(performAction: @escaping ([Location]) -> Void) {
        let db = Firestore.firestore()
     let docRef = db.collection("locations")
        var userList:[Location] = []
        //Get every single document under collection users
        let lat = 0.0144927536231884
            let lon = 0.0181818181818182

            let lowerLat = userLatitude - (lat * 10)
            let lowerLon = userLongitude - (lon * 10)

            let greaterLat = userLatitude + (lat * 10)
            let greaterLon = userLongitude + (lon * 10)

            let lesserGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
            let greaterGeopoint = GeoPoint(latitude: greaterLat, longitude: greaterLon)
        let query = docRef.whereField("location", isGreaterThan: lesserGeopoint).whereField("location", isLessThan: greaterGeopoint)
        docRef.getDocuments { (documents, error) in
           
        for document in documents!.documents {
                let result = Result {
                    try document.data(as: Location.self)
                }
                switch result {
                    case .success(let user):
                        if let user = user {
                            userList.append(user)
                 
                        } else {
                            
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
     
        
            }
              performAction(userList)
        }
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

struct SelectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}
