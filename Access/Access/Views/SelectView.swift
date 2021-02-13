//
//  SelectView.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI

struct SelectView: View {
    @State var locations = [Location(lat: 0.0, long: 0.0, title: "Home", subtitle: "Kitchen")]
    @State var open = false
    @State var add = false
    @State var config = false
    var body: some View {
        
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
        ForEach(locations) { location in
            LocationView(location: location, open: $open, config: $config)
                .padding()
        }
        Spacer()
            .sheet(isPresented: $open) {
                ZStack {
                if add {
                   AddView()
                    .onDisappear() {
                        add = false
                    }
                }
                if config {
                    ContentView()
                        .onDisappear() {
                            config = false
                        }
                }
            }
       }
    }
}

struct SelectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}
