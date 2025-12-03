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
            
            Text("Workout View") // We'll build this next
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }
            
            Text("Profile") // Placeholder
                .tabItem {
                    Label("You", systemImage: "person.circle.fill")
                }
        }
        .tint(.white) // Tab icon color when selected
    }
}

#Preview {
    ContentView()
}
