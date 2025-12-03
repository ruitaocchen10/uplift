//
//  TemplateViewModel.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation
import Combine

class TemplateViewModel: ObservableObject {
    @Published var templates: [WorkoutTemplate] = []
    @Published var selectedTemplate: WorkoutTemplate?
    @Published var isCreating: Bool = false
    @Published var isEditing: Bool = false
    
    private let storageManager = StorageManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTemplates()
        
        // Observe storage manager changes
        storageManager.$templates
            .assign(to: \.templates, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Template Management
    
    func loadTemplates() {
        templates = storageManager.templates
    }
    
    func createTemplate(_ template: WorkoutTemplate) {
        storageManager.addTemplate(template)
        isCreating = false
    }
    
    func updateTemplate(_ template: WorkoutTemplate) {
        storageManager.updateTemplate(template)
        isEditing = false
        selectedTemplate = nil
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        storageManager.deleteTemplate(template)
        if selectedTemplate?.id == template.id {
            selectedTemplate = nil
        }
    }
    
    func selectTemplate(_ template: WorkoutTemplate) {
        selectedTemplate = template
    }
    
    func deselectTemplate() {
        selectedTemplate = nil
    }
    
    // MARK: - Template Creation/Editing Helpers
    
    func startCreatingTemplate() {
        isCreating = true
        isEditing = false
    }
    
    func startEditingTemplate(_ template: WorkoutTemplate) {
        selectedTemplate = template
        isEditing = true
        isCreating = false
    }
    
    func cancelEditing() {
        isCreating = false
        isEditing = false
        selectedTemplate = nil
    }
    
    // MARK: - Template Queries
    
    func getTemplate(byId id: UUID) -> WorkoutTemplate? {
        templates.first { $0.id == id }
    }
    
    func getRecentlyUsedTemplates(limit: Int = 5) -> [WorkoutTemplate] {
        templates
            .filter { $0.lastUsedDate != nil }
            .sorted { ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }
    
    func searchTemplates(query: String) -> [WorkoutTemplate] {
        guard !query.isEmpty else { return templates }
        
        return templates.filter { template in
            template.name.localizedCaseInsensitiveContains(query) ||
            template.exercises.contains { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }
    
    // MARK: - Template Statistics
    
    func getTemplateUsageCount(_ templateId: UUID) -> Int {
        storageManager.workoutHistory.sessions
            .filter { $0.templateId == templateId && $0.isCompleted }
            .count
    }
    
    func getLastUsedDate(_ templateId: UUID) -> Date? {
        templates.first { $0.id == templateId }?.lastUsedDate
    }
    
    // MARK: - Validation
    
    func validateTemplate(_ template: WorkoutTemplate) -> (isValid: Bool, error: String?) {
        // Check if name is empty
        if template.name.trimmingCharacters(in: .whitespaces).isEmpty {
            return (false, "Template name cannot be empty")
        }
        
        // Check if there are exercises
        if template.exercises.isEmpty {
            return (false, "Template must have at least one exercise")
        }
        
        // Check if all exercises have names
        let hasUnnamedExercise = template.exercises.contains {
            $0.name.trimmingCharacters(in: .whitespaces).isEmpty
        }
        if hasUnnamedExercise {
            return (false, "All exercises must have a name")
        }
        
        // Check if all exercises have valid sets
        let hasInvalidSets = template.exercises.contains { $0.targetSets <= 0 }
        if hasInvalidSets {
            return (false, "All exercises must have at least 1 set")
        }
        
        // Check if all exercises have valid reps
        let hasInvalidReps = template.exercises.contains {
            $0.targetRepsMin <= 0 || $0.targetRepsMax <= 0 || $0.targetRepsMin > $0.targetRepsMax
        }
        if hasInvalidReps {
            return (false, "All exercises must have valid rep ranges")
        }
        
        return (true, nil)
    }
    
    // MARK: - Sample Templates
    
    func loadSampleTemplates() {
        let pushTemplate = WorkoutTemplate(
            name: "Hypertrophy Push Workout",
            exercises: [
                TemplateExercise(name: "Bench Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 0),
                TemplateExercise(name: "Overhead Press", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12, order: 1),
                TemplateExercise(name: "Incline Dumbbell Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 2),
                TemplateExercise(name: "Tricep Pushdown", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 3)
            ]
        )
        
        let pullTemplate = WorkoutTemplate(
            name: "Pull Day",
            exercises: [
                TemplateExercise(name: "Pull-ups", targetSets: 4, targetRepsMin: 8, targetRepsMax: 10, order: 0),
                TemplateExercise(name: "Barbell Row", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12, order: 1),
                TemplateExercise(name: "Lat Pulldown", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 2),
                TemplateExercise(name: "Face Pulls", targetSets: 3, targetRepsMin: 15, targetRepsMax: 20, order: 3)
            ]
        )
        
        let legsTemplate = WorkoutTemplate(
            name: "Leg Day",
            exercises: [
                TemplateExercise(name: "Squats", targetSets: 4, targetRepsMin: 8, targetRepsMax: 10, order: 0),
                TemplateExercise(name: "Romanian Deadlift", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12, order: 1),
                TemplateExercise(name: "Leg Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 2),
                TemplateExercise(name: "Leg Curls", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 3)
            ]
        )
        
        storageManager.addTemplate(pushTemplate)
        storageManager.addTemplate(pullTemplate)
        storageManager.addTemplate(legsTemplate)
    }
}
