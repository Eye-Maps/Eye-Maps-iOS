//
//  AddView.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI

struct AddView: View {
    @State var location =  Location(lat: 0.0, long: 0.0, title: "", subtitle: "")
    var body: some View {
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
    }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
