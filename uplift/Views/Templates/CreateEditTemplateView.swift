//
//  CreateEditTemplateView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import SwiftUI

// MARK: - Editing Exercise Wrapper

struct EditingExercise: Identifiable {
    let id = UUID()
    let index: Int
    let exercise: TemplateExercise
}

// MARK: - Selected Exercise Name Wrapper

struct SelectedExercise: Identifiable {
    let id = UUID()
    let name: String
}

struct CreateEditTemplateView: View {
    let template: WorkoutTemplate?
    let onSave: (WorkoutTemplate) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var templateName: String
    @State private var templateNotes: String
    @State private var exercises: [TemplateExercise]
    @State private var showingAddExercise = false
    @State private var editingExercise: EditingExercise?
    
    init(template: WorkoutTemplate?, onSave: @escaping (WorkoutTemplate) -> Void) {
        self.template = template
        self.onSave = onSave
        
        // Initialize state from template or with defaults
        _templateName = State(initialValue: template?.name ?? "")
        _templateNotes = State(initialValue: "")
        _exercises = State(initialValue: template?.exercises ?? [])
    }
    
    private var isValid: Bool {
        !templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !exercises.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Template Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Template Name")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            TextField("e.g., Push Day, Leg Day", text: $templateName)
                                .font(.futuraBody())
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                        }
                        .padding(.horizontal)
                        
                        // Notes (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            TextField("Add any notes about this template", text: $templateNotes, axis: .vertical)
                                .font(.futuraBody())
                                .foregroundColor(.white)
                                .lineLimit(3...6)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                        }
                        .padding(.horizontal)
                        
                        // Exercises Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Exercises")
                                    .font(.futuraHeadline())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if !exercises.isEmpty {
                                    Text("\(exercises.count)")
                                        .font(.futuraSubheadline())
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            
                            if exercises.isEmpty {
                                // Empty state for exercises
                                VStack(spacing: 16) {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("No exercises added yet")
                                        .font(.futuraBody())
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.3),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                                .padding(.horizontal)
                            } else {
                                // Exercise List
                                ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                                    TemplateExerciseRow(
                                        exercise: exercise,
                                        onTap: {
                                            editingExercise = EditingExercise(index: index, exercise: exercise)
                                        },
                                        onDelete: {
                                            deleteExercise(at: index)
                                        }
                                    )
                                }
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
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(template == nil ? "Create Template" : "Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CancelButton {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    SaveButton(enabled: isValid) {
                        saveTemplate()
                    }
                }
            }
            .standardToolbar()
            .sheet(isPresented: $showingAddExercise) {
                AddTemplateExerciseSheet { exercise in
                    exercises.append(exercise)
                }
            }
            .sheet(item: $editingExercise) { editingItem in
                EditTemplateExerciseSheet(
                    exercise: editingItem.exercise,
                    onSave: { updatedExercise in
                        exercises[editingItem.index] = updatedExercise
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveTemplate() {
        let trimmedName = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newTemplate = WorkoutTemplate(
            name: trimmedName,
            exercises: exercises
        )
        
        onSave(newTemplate)
        dismiss()
    }
    
    private func deleteExercise(at index: Int) {
        exercises.remove(at: index)
    }
}

// MARK: - Template Exercise Row

struct TemplateExerciseRow: View {
    let exercise: TemplateExercise
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text(exercise.displayString)
                        .font(.futuraSubheadline())
                        .foregroundColor(.gray)
                    
                    if let notes = exercise.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.futuraCaption())
                            .foregroundColor(.gray.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.futuraSubheadline())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
            )
            .fadeEdgeBorder(
                color: .white.opacity(0.4),
                cornerRadius: 12,
                lineWidth: 1,
                fadeStyle: .radial
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete Exercise", systemImage: "trash")
            }
        }
        .alert("Delete Exercise?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("This will remove \"\(exercise.name)\" from the template.")
        }
    }
}

// MARK: - Add Template Exercise Sheet

struct AddTemplateExerciseSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (TemplateExercise) -> Void
    
    @State private var searchText = ""
    @State private var selectedExercise: SelectedExercise?
    
    // Common exercises list
    private let commonExercises = [
        "Bench Press", "Squat", "Deadlift", "Overhead Press",
        "Barbell Row", "Pull-ups", "Dips", "Bicep Curls",
        "Tricep Extensions", "Leg Press", "Leg Curls", "Leg Extensions",
        "Lat Pulldown", "Cable Rows", "Face Pulls", "Lateral Raises",
        "Front Raises", "Rear Delt Fly", "Romanian Deadlift", "Lunges",
        "Incline Bench Press", "Decline Bench Press", "Chest Fly",
        "Hammer Curls", "Preacher Curls", "Tricep Dips", "Skull Crushers"
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
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                    )
                    .fadeEdgeBorder(
                        color: .white.opacity(0.4),
                        cornerRadius: 12,
                        lineWidth: 1,
                        fadeStyle: .radial
                    )
                    .padding()
                    
                    // Exercise list
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(filteredExercises, id: \.self) { exercise in
                                Button(action: {
                                    selectedExercise = SelectedExercise(name: exercise)
                                }) {
                                    HStack {
                                        Text(exercise)
                                            .font(.futuraBody())
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    .fadeEdgeBorder(
                                        color: .white.opacity(0.4),
                                        cornerRadius: 12,
                                        lineWidth: 1,
                                        fadeStyle: .radial
                                    )
                                }
                            }
                            
                            // Custom exercise option
                            if !searchText.isEmpty && !commonExercises.contains(searchText) {
                                Button(action: {
                                    selectedExercise = SelectedExercise(name: searchText)
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
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green.opacity(0.2))
                                    )
                                    .fadeEdgeBorder(
                                        color: .green.opacity(0.5),
                                        cornerRadius: 12,
                                        lineWidth: 1,
                                        fadeStyle: .radial
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CancelButton {
                        dismiss()
                    }
                }
            }
            .standardToolbar()
            .sheet(item: $selectedExercise) { selected in
                ConfigureExerciseSheet(
                    exerciseName: selected.name,
                    onSave: { exercise in
                        onAdd(exercise)
                        dismiss()
                    }
                )
            }
        }
    }
}

// MARK: - Configure Exercise Sheet

struct ConfigureExerciseSheet: View {
    let exerciseName: String
    let onSave: (TemplateExercise) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var targetSets: Int = 3
    @State private var targetRepsMin: Int = 8
    @State private var targetRepsMax: Int = 12
    @State private var notes: String = ""
    @State private var useSameReps: Bool = false
    
    private var isValid: Bool {
        targetSets > 0 && targetRepsMin > 0 && targetRepsMax >= targetRepsMin
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Exercise Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercise")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            Text(exerciseName)
                                .font(.futuraTitle3())
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                        }
                        .padding(.horizontal)
                        
                        // Target Sets
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Sets")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            HStack {
                                Button(action: {
                                    targetSets = max(1, targetSets - 1)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.futuraTitle2())
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Text("\(targetSets)")
                                    .font(.futuraTitle())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    targetSets += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.futuraTitle2())
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .fadeEdgeBorder(
                                color: .white.opacity(0.4),
                                cornerRadius: 12,
                                lineWidth: 1,
                                fadeStyle: .radial
                            )
                        }
                        .padding(.horizontal)
                        
                        // Target Reps
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Reps")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            // Same reps toggle
                            Toggle(isOn: $useSameReps) {
                                Text("Use same rep count")
                                    .font(.futuraBody())
                                    .foregroundColor(.white)
                            }
                            .tint(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .fadeEdgeBorder(
                                color: .white.opacity(0.4),
                                cornerRadius: 12,
                                lineWidth: 1,
                                fadeStyle: .radial
                            )
                            
                            if useSameReps {
                                // Single rep count
                                HStack {
                                    Button(action: {
                                        targetRepsMin = max(1, targetRepsMin - 1)
                                        targetRepsMax = targetRepsMin
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.futuraTitle2())
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(targetRepsMin)")
                                        .font(.futuraTitle())
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        targetRepsMin += 1
                                        targetRepsMax = targetRepsMin
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.futuraTitle2())
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                            } else {
                                // Rep range
                                VStack(spacing: 12) {
                                    // Min reps
                                    HStack {
                                        Text("Min")
                                            .font(.futuraBody())
                                            .foregroundColor(.gray)
                                            .frame(width: 50, alignment: .leading)
                                        
                                        Button(action: {
                                            targetRepsMin = max(1, targetRepsMin - 1)
                                            if targetRepsMin > targetRepsMax {
                                                targetRepsMax = targetRepsMin
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.futuraTitle3())
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(targetRepsMin)")
                                            .font(.futuraTitle2())
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            targetRepsMin += 1
                                            if targetRepsMin > targetRepsMax {
                                                targetRepsMax = targetRepsMin
                                            }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.futuraTitle3())
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    .fadeEdgeBorder(
                                        color: .white.opacity(0.4),
                                        cornerRadius: 12,
                                        lineWidth: 1,
                                        fadeStyle: .radial
                                    )
                                    
                                    // Max reps
                                    HStack {
                                        Text("Max")
                                            .font(.futuraBody())
                                            .foregroundColor(.gray)
                                            .frame(width: 50, alignment: .leading)
                                        
                                        Button(action: {
                                            targetRepsMax = max(targetRepsMin, targetRepsMax - 1)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.futuraTitle3())
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(targetRepsMax)")
                                            .font(.futuraTitle2())
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            targetRepsMax += 1
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.futuraTitle3())
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    .fadeEdgeBorder(
                                        color: .white.opacity(0.4),
                                        cornerRadius: 12,
                                        lineWidth: 1,
                                        fadeStyle: .radial
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            TextField("e.g., Focus on form, pause at bottom", text: $notes, axis: .vertical)
                                .font(.futuraBody())
                                .foregroundColor(.white)
                                .lineLimit(2...4)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Configure Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CancelButton {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    SaveButton(enabled: isValid) {
                        let exercise = TemplateExercise(
                            name: exerciseName,
                            targetSets: targetSets,
                            targetRepsMin: targetRepsMin,
                            targetRepsMax: targetRepsMax,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(exercise)
                        dismiss()
                    }
                }
            }
            .standardToolbar()
        }
    }
}

// MARK: - Edit Template Exercise Sheet

struct EditTemplateExerciseSheet: View {
    let exercise: TemplateExercise
    let onSave: (TemplateExercise) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var targetSets: Int
    @State private var targetRepsMin: Int
    @State private var targetRepsMax: Int
    @State private var notes: String
    @State private var useSameReps: Bool
    
    init(exercise: TemplateExercise, onSave: @escaping (TemplateExercise) -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        
        _targetSets = State(initialValue: exercise.targetSets)
        _targetRepsMin = State(initialValue: exercise.targetRepsMin)
        _targetRepsMax = State(initialValue: exercise.targetRepsMax)
        _notes = State(initialValue: exercise.notes ?? "")
        _useSameReps = State(initialValue: exercise.targetRepsMin == exercise.targetRepsMax)
    }
    
    private var isValid: Bool {
        targetSets > 0 && targetRepsMin > 0 && targetRepsMax >= targetRepsMin
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Exercise Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercise")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            Text(exercise.name)
                                .font(.futuraTitle3())
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                        }
                        .padding(.horizontal)
                        
                        // Target Sets
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Sets")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            HStack {
                                Button(action: {
                                    targetSets = max(1, targetSets - 1)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.futuraTitle2())
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Text("\(targetSets)")
                                    .font(.futuraTitle())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    targetSets += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.futuraTitle2())
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .fadeEdgeBorder(
                                color: .white.opacity(0.4),
                                cornerRadius: 12,
                                lineWidth: 1,
                                fadeStyle: .radial
                            )
                        }
                        .padding(.horizontal)
                        
                        // Target Reps
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Reps")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            // Same reps toggle
                            Toggle(isOn: $useSameReps) {
                                Text("Use same rep count")
                                    .font(.futuraBody())
                                    .foregroundColor(.white)
                            }
                            .tint(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .fadeEdgeBorder(
                                color: .white.opacity(0.4),
                                cornerRadius: 12,
                                lineWidth: 1,
                                fadeStyle: .radial
                            )
                            
                            if useSameReps {
                                // Single rep count
                                HStack {
                                    Button(action: {
                                        targetRepsMin = max(1, targetRepsMin - 1)
                                        targetRepsMax = targetRepsMin
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.futuraTitle2())
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(targetRepsMin)")
                                        .font(.futuraTitle())
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        targetRepsMin += 1
                                        targetRepsMax = targetRepsMin
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.futuraTitle2())
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                            } else {
                                // Rep range
                                VStack(spacing: 12) {
                                    // Min reps
                                    HStack {
                                        Text("Min")
                                            .font(.futuraBody())
                                            .foregroundColor(.gray)
                                            .frame(width: 50, alignment: .leading)
                                        
                                        Button(action: {
                                            targetRepsMin = max(1, targetRepsMin - 1)
                                            if targetRepsMin > targetRepsMax {
                                                targetRepsMax = targetRepsMin
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.futuraTitle3())
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(targetRepsMin)")
                                            .font(.futuraTitle2())
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            targetRepsMin += 1
                                            if targetRepsMin > targetRepsMax {
                                                targetRepsMax = targetRepsMin
                                            }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.futuraTitle3())
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    .fadeEdgeBorder(
                                        color: .white.opacity(0.4),
                                        cornerRadius: 12,
                                        lineWidth: 1,
                                        fadeStyle: .radial
                                    )
                                    
                                    // Max reps
                                    HStack {
                                        Text("Max")
                                            .font(.futuraBody())
                                            .foregroundColor(.gray)
                                            .frame(width: 50, alignment: .leading)
                                        
                                        Button(action: {
                                            targetRepsMax = max(targetRepsMin, targetRepsMax - 1)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.futuraTitle3())
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(targetRepsMax)")
                                            .font(.futuraTitle2())
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            targetRepsMax += 1
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.futuraTitle3())
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    .fadeEdgeBorder(
                                        color: .white.opacity(0.4),
                                        cornerRadius: 12,
                                        lineWidth: 1,
                                        fadeStyle: .radial
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                            
                            TextField("e.g., Focus on form, pause at bottom", text: $notes, axis: .vertical)
                                .font(.futuraBody())
                                .foregroundColor(.white)
                                .lineLimit(2...4)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CancelButton {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    SaveButton(enabled: isValid) {
                        let updatedExercise = TemplateExercise(
                            name: exercise.name,
                            targetSets: targetSets,
                            targetRepsMin: targetRepsMin,
                            targetRepsMax: targetRepsMax,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(updatedExercise)
                        dismiss()
                    }
                }
            }
            .standardToolbar()
        }
    }
}

#Preview {
    CreateEditTemplateView(template: nil) { _ in }
}
