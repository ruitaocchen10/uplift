//
//  HomeView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Ruitao Chen")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar Week View
                    CalendarWeekView(selectedDate: $selectedDate)
                        .padding(.horizontal)
                    
                    // Workout Section
                    HStack {
                        Text("Hypertrophy Push Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Templates")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Workout Cards
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(0..<4) { _ in
                                WorkoutCard(
                                    exerciseName: "Bench Press",
                                    sets: "3 sets x 12-15 reps"
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
    }
}

// Calendar Week View Component
struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let dates = [7, 8, 9, 10, 11, 12, 13]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("July 2025")
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(0..<7) { index in
                    VStack(spacing: 8) {
                        Text(daysOfWeek[index])
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(dates[index])")
                            .font(.title3)
                            .foregroundColor(index == 3 ? .black : .white)
                            .frame(width: 40, height: 40)
                            .background(index == 3 ? Color.white : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// Workout Card Component
struct WorkoutCard: View {
    let exerciseName: String
    let sets: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exerciseName)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(sets)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
}
