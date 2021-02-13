//
//  LocationView.swift
//  Access
//
//  Created by Andreas on 2/13/21.
//

import SwiftUI

struct LocationView: View {
    @Binding var location: Location
    @Binding var open: Bool
    @Binding var config: Bool
    
    var body: some View {
        
          
        
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(.blue)
                .opacity(0.4)
                .frame(maxHeight: 200)
        VStack {
            HStack {
                Text(location.title)
                    .foregroundColor(.white)
                    .font(.title)
                    .bold()
                Spacer()
            } .padding()
            
            HStack {
                Text(location.subtitle)
                    .foregroundColor(.white)
                    .font(.subheadline)
                Spacer()
            }.padding()
        }
    }
    }


}
