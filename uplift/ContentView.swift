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
                        .font(.futuraBody())
                }
            
            Text("Workout View") // We'll build this next
                .font(.futuraBody())
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                        .font(.futuraBody())
                }
            
            Text("Profile") // Placeholder
                .font(.futuraBody())
                .tabItem {
                    Label("You", systemImage: "person.circle.fill")
                        .font(.futuraBody())
                }
        }
        .tint(.white) // Tab icon color when selected
        .preferredColorScheme(.dark) // Force dark mode
    }
}

#Preview {
    ContentView()
}
