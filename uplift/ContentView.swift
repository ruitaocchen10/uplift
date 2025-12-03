//
//  ContentView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var workoutViewModel = WorkoutViewModel()
    
    var body: some View {
        TabView {
            HomeView(workoutViewModel: workoutViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                        .font(.futuraBody())
                }
            
            WorkoutTabView(workoutViewModel: workoutViewModel)
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                        .font(.futuraBody())
                }
                .badge(workoutViewModel.isWorkoutActive ? "•" : nil)
            
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

// MARK: - Workout Tab View

struct WorkoutTabView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if workoutViewModel.isWorkoutActive {
                    // Show active workout with resume button
                    VStack(spacing: 24) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 8) {
                            Text("Workout In Progress")
                                .font(.futuraTitle2())
                                .foregroundColor(.white)
                            
                            if let session = workoutViewModel.currentSession {
                                Text(session.templateName ?? "Workout")
                                    .font(.futuraHeadline())
                                    .foregroundColor(.gray)
                                
                                Text("\(session.completedSets)/\(session.totalSets) sets completed")
                                    .font(.futuraBody())
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        NavigationLink(destination: WorkoutLoggingView(viewModel: workoutViewModel)) {
                            Text("Continue Workout")
                                .font(.futuraHeadline())
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    // No active workout
                    VStack(spacing: 24) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Active Workout")
                            .font(.futuraTitle2())
                            .foregroundColor(.white)
                        
                        Text("Start a workout from the Home tab")
                            .font(.futuraBody())
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
