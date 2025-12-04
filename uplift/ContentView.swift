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
            TemplatesView()
                .tabItem {
                    Label("Templates", systemImage: "list.clipboard.fill")
                }
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
