//
//  AddView.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI

struct AddView: View {
    @Binding var locations: [Location]
    @State var location =  Location(lat: 0.0, long: 0.0, title: "", subtitle: "")
    @State var next = false
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
         
            Spacer()
            Button(action: {
               
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
    }
            if next {
                ZStack {
                Color.white
                    ContentView(location: $locations[locations.count - 1])
                  
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


