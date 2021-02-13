//
//  SelectView.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI

struct SelectView: View {
    @State var locations = [Location]()
    @State var open = false
    @State var add = false
    @State var config = false
    @State var i3 = 0
    @State var ready = false
    @ObservedObject var locationManager = LocationManager()

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
        }
            
            
        } .padding()
        ForEach(locations.indices) { i in
            Button(action: {
                config = true
                open = true
                self.i3 = i
            }) {
            LocationView(location: $locations[i], open: $open, config: $config)
                .padding()
            }
        }
        .onChange(of: locations, perform: { value in
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(locations) {
            if let json = String(data: encoded, encoding: .utf8) {
                print(json)
                do {
                    var url = self.getDocumentsDirectory().appendingPathComponent("locations.txt")
                   
                    try json.write(to: url, atomically: true, encoding: String.Encoding.utf8)
                
                } catch {
                    print("erorr")
                }
                }

           
        }
       
    })
        Spacer()
            .sheet(isPresented: $open) {
                ZStack {
                if add {
                   AddView(locations: $locations)
                    .onDisappear() {
                        add = false
                    }
                }
                if config {
                    ContentView(location: $locations[i3])
                        .onDisappear() {
                            config = false
                        }
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

struct SelectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}
