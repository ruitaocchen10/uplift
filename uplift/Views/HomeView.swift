//
//  HomeView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var templateViewModel = TemplateViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @StateObject private var storageManager = StorageManager.shared
    
    @State private var selectedDate = Date()
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showingTemplateSelector = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back")
                                .font(.futuraSubheadline())
                                .foregroundColor(.gray)
                            Text(storageManager.userProfile?.name ?? "User")
                                .font(.futuraTitle2())
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.futuraTitle3())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar Week View
                    CalendarWeekView(
                        selectedDate: $selectedDate,
                        datesWithWorkouts: progressViewModel.getDatesWithWorkouts()
                    )
                    .padding(.horizontal)
                    
                    // Workout Section
                    HStack {
                        if let template = selectedTemplate {
                            Text(template.name)
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                        } else {
                            Text("Select a Workout")
                                .font(.futuraHeadline())
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingTemplateSelector = true
                        }) {
                            Text("Templates")
                                .font(.futuraSubheadline())
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Workout Cards or Empty State
                    ScrollView {
                        if let template = selectedTemplate {
                            VStack(spacing: 12) {
                                ForEach(template.exercises.sorted(by: { $0.order < $1.order })) { exercise in
                                    WorkoutCard(
                                        exerciseName: exercise.name,
                                        sets: exercise.displayString
                                    )
                                }
                                
                                // Start Workout Button
                                Button(action: {
                                    workoutViewModel.startWorkout(from: template)
                                }) {
                                    Text("Start Workout")
                                        .font(.futuraHeadline())
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                                .padding(.top, 8)
                            }
                            .padding(.horizontal)
                        } else {
                            // Empty state
                            VStack(spacing: 16) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No workout selected")
                                    .font(.futuraHeadline())
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    showingTemplateSelector = true
                                }) {
                                    Text("Choose a Template")
                                        .font(.futuraBody())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .sheet(isPresented: $showingTemplateSelector) {
                TemplateSelectionSheet(
                    templates: templateViewModel.templates,
                    selectedTemplate: $selectedTemplate,
                    onLoadSample: {
                        templateViewModel.loadSampleTemplates()
                    }
                )
            }
            .onAppear {
                // Load first template by default if available
                if selectedTemplate == nil && !templateViewModel.templates.isEmpty {
                    selectedTemplate = templateViewModel.templates.first
                }
            }
        }
    }
}

// Calendar Week View Component
struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    let datesWithWorkouts: Set<Date>
    
    private let calendar = Calendar.current
    
    // Get the current week dates
    private var weekDates: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: selectedDate) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = weekInterval.start
        
        for _ in 0..<7 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthYearString)
                .font(.futuraTitle3())
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(weekDates, id: \.self) { date in
                    let dayOfWeek = calendar.component(.weekday, from: date)
                    let dayNumber = calendar.component(.day, from: date)
                    let isToday = calendar.isDateInToday(date)
                    let hasWorkout = datesWithWorkouts.contains(calendar.startOfDay(for: date))
                    
                    VStack(spacing: 8) {
                        Text(weekdaySymbol(for: dayOfWeek))
                            .font(.futuraCaption())
                            .foregroundColor(.gray)
                        
                        ZStack {
                            Text("\(dayNumber)")
                                .font(.futuraTitle3())
                                .foregroundColor(isToday ? .black : .white)
                                .frame(width: 40, height: 40)
                                .background(isToday ? Color.white : Color.clear)
                                .cornerRadius(8)
                            
                            // Workout indicator dot
                            if hasWorkout {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 12, y: -12)
                            }
                        }
                    }
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
        }
    }
    
    private func weekdaySymbol(for weekday: Int) -> String {
        let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return symbols[weekday - 1]
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
                    .font(.futuraHeadline())
                    .foregroundColor(.white)
                Text(sets)
                    .font(.futuraSubheadline())
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

// Template Selection Sheet
struct TemplateSelectionSheet: View {
    let templates: [WorkoutTemplate]
    @Binding var selectedTemplate: WorkoutTemplate?
    let onLoadSample: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if templates.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Templates Yet")
                            .font(.futuraTitle3())
                            .foregroundColor(.white)
                        
                        Text("Create your first workout template or load sample templates to get started")
                            .font(.futuraBody())
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            onLoadSample()
                        }) {
                            Text("Load Sample Templates")
                                .font(.futuraHeadline())
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    // Template list
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(templates) { template in
                                Button(action: {
                                    selectedTemplate = template
                                    dismiss()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(template.name)
                                                .font(.futuraHeadline())
                                                .foregroundColor(.white)
                                            
                                            Text("\(template.totalExercises) exercises")
                                                .font(.futuraSubheadline())
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedTemplate?.id == template.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
