//
//  WorkoutLoggingView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import SwiftUI

struct WorkoutLoggingView: View {
    @Binding var workout: WorkoutSession
    @Environment(\.dismiss) var dismiss
    
    @State private var showingFinishConfirmation = false
    @State private var showingCancelConfirmation = false
    @State private var showingAddExercise = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Exercise List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseCard(
                                exercise: $workout.exercises[index],
                                onDelete: {
                                    deleteExercise(at: index)
                                }
                            )
                        }
                        
                        // Add Exercise Button
                        Button(action: {
                            showingAddExercise = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.futuraTitle3())
                                Text("Add Exercise")
                                    .font(.futuraHeadline())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                // Finish Workout Button
                finishWorkoutButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseSheet { exerciseName in
                let newExercise = Exercise(
                    name: exerciseName,
                    sets: [WorkoutSet()],
                    isExpanded: true
                )
                workout.exercises.append(newExercise)
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.futuraTitle3())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(workout.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text("\(workout.completedSets)/\(workout.totalSets) sets")
                        .font(.futuraCaption())
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    showingCancelConfirmation = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.futuraTitle3())
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * workout.progressPercentage, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
        }
        .padding(.bottom, 12)
        .background(Color.black)
        .alert("Cancel Workout?", isPresented: $showingCancelConfirmation) {
            Button("Keep Editing", role: .cancel) {}
            Button("Discard Workout", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("This will discard all your progress.")
        }
    }
    
    // MARK: - Finish Workout Button
    
    private var finishWorkoutButton: some View {
        Button(action: {
            showingFinishConfirmation = true
        }) {
            Text("Finish Workout")
                .font(.futuraHeadline())
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding()
        .background(Color.black)
        .alert("Finish Workout?", isPresented: $showingFinishConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Finish") {
                workout.isCompleted = true
                dismiss()
            }
        } message: {
            Text("You completed \(workout.completedSets) of \(workout.totalSets) sets.")
        }
    }
    
    // MARK: - Helper Methods
    
    private func deleteExercise(at index: Int) {
        workout.exercises.remove(at: index)
    }
}

// MARK: - Exercise Card

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Exercise Header
            Button(action: {
                exercise.isExpanded.toggle()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.futuraHeadline())
                            .foregroundColor(.white)
                        
                        Text("\(exercise.completedSetsCount)/\(exercise.totalSets) sets")
                            .font(.futuraCaption())
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: exercise.isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                        .font(.futuraSubheadline())
                }
                .padding()
                .background(Color.gray.opacity(0.2))
            }
            
            // Expanded Content
            if exercise.isExpanded {
                VStack(spacing: 8) {
                    // Set rows
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                        SetRow(
                            setNumber: index + 1,
                            set: $exercise.sets[index]
                        )
                    }
                    
                    // Add Set Button
                    Button(action: {
                        addSet()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Set")
                        }
                        .font(.futuraSubheadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Delete Exercise Button
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Text("Delete Exercise")
                            .font(.futuraSubheadline())
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                .background(Color.gray.opacity(0.2))
            }
        }
        .cornerRadius(12)
        .padding(.horizontal)
        .alert("Delete Exercise?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This will remove \(exercise.name) from your workout.")
        }
    }
    
    private func addSet() {
        let lastSet = exercise.sets.last
        let newSet = WorkoutSet(
            weight: lastSet?.weight ?? 0,
            reps: lastSet?.reps ?? 0,
            isCompleted: false
        )
        exercise.sets.append(newSet)
    }
}

// MARK: - Set Row

struct SetRow: View {
    let setNumber: Int
    @Binding var set: WorkoutSet
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case weight, reps
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Set number
            Text("\(setNumber)")
                .font(.futuraBody())
                .foregroundColor(.gray)
                .frame(width: 30)
            
            // Weight input with steppers
            HStack(spacing: 4) {
                Button(action: {
                    set.weight = max(0, set.weight - 5)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
                
                TextField("0", value: $set.weight, format: .number)
                    .font(.futuraBody())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .weight)
                    .frame(width: 50)
                
                Button(action: {
                    set.weight += 5
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
                
                Text("lbs")
                    .font(.futuraCaption())
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // Reps input with steppers
            HStack(spacing: 4) {
                Button(action: {
                    set.reps = max(0, set.reps - 1)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
                
                TextField("0", value: $set.reps, format: .number)
                    .font(.futuraBody())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .reps)
                    .frame(width: 40)
                
                Button(action: {
                    set.reps += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
            }
            .frame(maxWidth: .infinity)
            
            // Completion checkmark
            Button(action: {
                set.isCompleted.toggle()
            }) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.isCompleted ? .green : .gray)
                    .font(.futuraTitle3())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(set.isCompleted ? Color.green.opacity(0.1) : Color.clear)
    }
}

// MARK: - Add Exercise Sheet

struct AddExerciseSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (String) -> Void
    
    @State private var searchText = ""
    
    // Common exercises list
    private let commonExercises = [
        "Bench Press", "Squat", "Deadlift", "Overhead Press",
        "Barbell Row", "Pull-ups", "Dips", "Bicep Curls",
        "Tricep Extensions", "Leg Press", "Leg Curls", "Leg Extensions",
        "Lat Pulldown", "Cable Rows", "Face Pulls", "Lateral Raises",
        "Front Raises", "Rear Delt Fly", "Romanian Deadlift", "Lunges"
    ].sorted()
    
    private var filteredExercises: [String] {
        if searchText.isEmpty {
            return commonExercises
        }
        return commonExercises.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search exercises", text: $searchText)
                            .font(.futuraBody())
                            .foregroundColor(.white)
                            .autocapitalization(.words)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding()
                    
                    // Exercise list
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(filteredExercises, id: \.self) { exercise in
                                Button(action: {
                                    onAdd(exercise)
                                    dismiss()
                                }) {
                                    HStack {
                                        Text(exercise)
                                            .font(.futuraBody())
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Custom exercise option
                            if !searchText.isEmpty && !commonExercises.contains(searchText) {
                                Button(action: {
                                    onAdd(searchText)
                                    dismiss()
                                }) {
                                    HStack {
                                        Text("Add \"\(searchText)\"")
                                            .font(.futuraBody())
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Add Exercise")
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

#Preview {
    WorkoutLoggingView(workout: .constant(DummyData.activeWorkout))
}
