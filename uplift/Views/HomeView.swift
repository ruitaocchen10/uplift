//
//  HomeView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedDate = Date()
    @State private var showingTemplateSelector = false
    @State private var showingFullCalendar = false
    @State private var showingWorkoutDetail: WorkoutSession?
    
    // DUMMY DATA - Replace with real data later
    private let dummyWorkouts = DummyData.sampleWorkouts
    private let dummyDatesWithWorkouts = DummyData.datesWithWorkouts
    
    // Filter workouts for selected date
    private var workoutsForSelectedDate: [WorkoutSession] {
        dummyWorkouts.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private var completedWorkouts: [WorkoutSession] {
        workoutsForSelectedDate.filter { $0.isCompleted }
    }
    
    private var inProgressWorkouts: [WorkoutSession] {
        workoutsForSelectedDate.filter { !$0.isCompleted }
    }
    
    private var hasWorkoutsOnSelectedDate: Bool {
        !workoutsForSelectedDate.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerView
                    
                    // Calendar Week View with Navigation
                    calendarSection
                    
                    // Content based on selected date
                    ScrollView {
                        VStack(spacing: 16) {
                            // Show completed workouts
                            if !completedWorkouts.isEmpty {
                                ForEach(completedWorkouts) { workout in
                                    CompletedWorkoutCard(workout: workout)
                                        .onTapGesture {
                                            showingWorkoutDetail = workout
                                        }
                                }
                            }
                            
                            // Show in-progress workouts
                            if !inProgressWorkouts.isEmpty {
                                ForEach(inProgressWorkouts) { workout in
                                    InProgressWorkoutCard(workout: workout) {
                                        // TODO: Resume workout navigation
                                    }
                                }
                            }
                            
                            // Show template selector for empty dates or add another workout
                            if !hasWorkoutsOnSelectedDate {
                                EmptyDateView {
                                    showingTemplateSelector = true
                                }
                            } else {
                                // Allow adding another workout to the same day
                                Button(action: {
                                    showingTemplateSelector = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.futuraTitle3())
                                        Text("Add Another Workout")
                                            .font(.futuraHeadline())
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .sheet(isPresented: $showingTemplateSelector) {
                TemplateSelectionSheet(
                    templates: DummyData.sampleTemplates,
                    selectedDate: selectedDate,
                    onTemplateSelected: { template in
                        // TODO: Start workout from template
                        print("Selected template: \(template.name)")
                    }
                )
            }
            .sheet(isPresented: $showingFullCalendar) {
                FullCalendarPicker(selectedDate: $selectedDate)
            }
            .sheet(item: $showingWorkoutDetail) { workout in
                WorkoutDetailSheet(workout: workout)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Welcome back")
                    .font(.futuraSubheadline())
                    .foregroundColor(.gray)
                Text("Ruitao Chen")
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
    }
    
    private var calendarSection: some View {
        VStack(spacing: 8) {
            // Month/Year header (tappable for full calendar)
            Button(action: {
                showingFullCalendar = true
            }) {
                HStack {
                    Text(monthYearString)
                        .font(.futuraTitle3())
                        .foregroundColor(.white)
                    
                    Image(systemName: "calendar")
                        .font(.futuraSubheadline())
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Week navigation with arrows
            HStack(spacing: 0) {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.futuraTitle3())
                        .frame(width: 30)
                }
                
                Spacer()
                
                CalendarWeekView(
                    selectedDate: $selectedDate,
                    datesWithWorkouts: dummyDatesWithWorkouts
                )
                
                Spacer()
                
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.futuraTitle3())
                        .frame(width: 30)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Methods
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func previousWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
    }
}

// MARK: - Calendar Week View Component

struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    let datesWithWorkouts: Set<Date>
    
    private let calendar = Calendar.current
    
    // Get the week dates starting from Sunday
    private var weekDates: [Date] {
        let weekday = calendar.component(.weekday, from: selectedDate)
        let daysToSubtract = weekday - 1
        
        guard let weekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: selectedDate) else {
            return []
        }
        
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekStart) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDates, id: \.self) { date in
                let dayOfWeek = calendar.component(.weekday, from: date)
                let dayNumber = calendar.component(.day, from: date)
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                let hasWorkout = datesWithWorkouts.contains(calendar.startOfDay(for: date))
                
                VStack(spacing: 4) {
                    Text(weekdaySymbol(for: dayOfWeek))
                        .font(.futuraCaption())
                        .foregroundColor(.gray)
                    
                    ZStack {
                        Text("\(dayNumber)")
                            .font(.futuraBody())
                            .foregroundColor(isSelected ? .black : .white)
                            .frame(width: 36, height: 36)
                            .background(isSelected ? Color.white : (isToday ? Color.gray.opacity(0.3) : Color.clear))
                            .cornerRadius(8)
                        
                        // Workout indicator dot
                        if hasWorkout {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 5, height: 5)
                                .offset(x: 11, y: -11)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
    }
    
    private func weekdaySymbol(for weekday: Int) -> String {
        let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return symbols[weekday - 1]
    }
}

// MARK: - Workout Cards

struct CompletedWorkoutCard: View {
    let workout: WorkoutSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Label("\(workout.exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
                        Label("\(Int(workout.totalVolume)) lbs", systemImage: "scalemass")
                    }
                    .font(.futuraCaption())
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.futuraTitle3())
            }
            
            Text("Tap to view details")
                .font(.futuraCaption())
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

struct InProgressWorkoutCard: View {
    let workout: WorkoutSession
    let onResume: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text("\(workout.completedSets)/\(workout.totalSets) sets completed")
                        .font(.futuraCaption())
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                    .font(.futuraTitle3())
            }
            
            Button(action: onResume) {
                Text("Resume Workout")
                    .font(.futuraHeadline())
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(12)
    }
}

struct EmptyDateView: View {
    let onAddWorkout: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No workout on this day")
                .font(.futuraHeadline())
                .foregroundColor(.gray)
            
            Button(action: onAddWorkout) {
                Text("Add Workout")
                    .font(.futuraHeadline())
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Sheet Views

struct TemplateSelectionSheet: View {
    let templates: [WorkoutTemplate]
    let selectedDate: Date
    let onTemplateSelected: (WorkoutTemplate) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(templates) { template in
                            Button(action: {
                                onTemplateSelected(template)
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(template.name)
                                            .font(.futuraHeadline())
                                            .foregroundColor(.white)
                                        
                                        Text("\(template.totalExercises) exercises • ~\(template.estimatedDuration) min")
                                            .font(.futuraSubheadline())
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
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
            .navigationTitle("Select Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct FullCalendarPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .colorScheme(.dark)
                .padding()
            }
            .navigationTitle("Select Date")
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

struct WorkoutDetailSheet: View {
    let workout: WorkoutSession
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Workout Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(workout.templateName ?? "Workout")
                                .font(.futuraTitle2())
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                Label("\(workout.exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
                                Label("\(Int(workout.totalVolume)) lbs", systemImage: "scalemass")
                            }
                            .font(.futuraSubheadline())
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .background(Color.gray)
                        
                        // Exercises
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Exercises")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(workout.exercises) { exercise in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(exercise.name)
                                        .font(.futuraHeadline())
                                        .foregroundColor(.white)
                                    
                                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                                        HStack {
                                            Text("Set \(index + 1)")
                                                .font(.futuraBody())
                                                .foregroundColor(.gray)
                                            
                                            Spacer()
                                            
                                            Text("\(Int(set.weight)) lbs × \(set.reps) reps")
                                                .font(.futuraBody())
                                                .foregroundColor(.white)
                                            
                                            if set.isCompleted {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Workout Details")
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
