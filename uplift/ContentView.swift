//
//  ContentView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            Text("Workout View") // TODO: Build WorkoutLoggingView
                .font(.futuraBody())
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }
            
            Text("Profile") // TODO: Build ProfileView
                .font(.futuraBody())
                .tabItem {
                    Label("You", systemImage: "person.circle.fill")
                }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
