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

struct ContentView : View {
    @State var config = false
    @State var use = false
    
    var body: some View {
        ZStack {
        VStack{
            
            Button(action: {
                config = true
            }) {
                Text("Config")
            }
            .padding()
            Button(action: {
                use = true
            }) {
                Text("Use")
            } .padding()
        }
            if config {
                VStack {
                    HStack {
                        Button(action: {
                            config = false
                        }) {
                            Image(systemName: "xmark")
                        } .padding()
                        Spacer()
                    }
                ConfigureView()
                }
            }
            if use {
                VStack {
                    HStack {
                        Button(action: {
                            use = false
                        }) {
                            Image(systemName: "xmark")
                        } .padding()
                        Spacer()
                    }
                UseView()
            }
            }
    }
    }
    
    
  
    
}
