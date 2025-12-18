//
//  CloudDataSource.swift
//  uplift
//
//  Created by Ruitao Chen on 12/18/25.
//

import Foundation
import CloudKit

/// Handles all cloud database operations using CloudKit
class CloudDataSource {
    
    // MARK: - Properties
    
    private let container: CKContainer
    private let database: CKDatabase
    
    // MARK: - CloudKit Record Types
    
    private let workoutRecordType = "WorkoutSession"
    private let templateRecordType = "WorkoutTemplate"
    
    // MARK: - Initialization
    
    init() {
        // Use default container (configured in Signing & Capabilities)
        self.container = CKContainer.default()
        
        // Use private database (user's personal data)
        self.database = container.privateCloudDatabase
    }
    
    // MARK: - Workout Operations
    
    /// Fetch all workouts from CloudKit
    func fetchAllWorkouts() async throws -> [WorkoutSession] {
        print("☁️ Fetching workouts from CloudKit...")
        
        // Create query to get all workouts
        let query = CKQuery(
            recordType: workoutRecordType,
            predicate: NSPredicate(value: true)  // Get all records
        )
        
        // Sort by date (newest first)
        query.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        do {
            // Execute query
            let (matchResults, _) = try await database.records(matching: query)
            
            // Convert CKRecords to WorkoutSession objects
            var workouts: [WorkoutSession] = []
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    if let workout = convertRecordToWorkout(record) {
                        workouts.append(workout)
                    }
                case .failure(let error):
                    print("❌ Failed to fetch record: \(error)")
                }
            }
            
            print("✅ Fetched \(workouts.count) workouts from CloudKit")
            return workouts
            
        } catch {
            print("❌ CloudKit fetch failed: \(error)")
            throw error
        }
    }
    
    /// Save Workout (with proper update logic)

    func saveWorkout(_ workout: WorkoutSession) async throws {
        let recordID = CKRecord.ID(recordName: workout.id.uuidString)
        
        // Try to fetch existing record first
        let record: CKRecord
        do {
            // If record exists, fetch it for updating
            record = try await database.record(for: recordID)
            print("📝 Updating existing workout: \(workout.templateName ?? "Workout")")
        } catch {
            // If record doesn't exist, create new one
            record = CKRecord(recordType: workoutRecordType, recordID: recordID)
            print("📝 Creating new workout: \(workout.templateName ?? "Workout")")
        }
        
        // Set fields (same as before)
        record["templateName"] = workout.templateName
        record["date"] = workout.date
        record["isCompleted"] = workout.isCompleted
        record["notes"] = workout.notes
        
        // Serialize exercises to JSON using helper method
        let exercisesJSON = convertExercisesToJSON(workout.exercises)
        record["exercisesJSON"] = exercisesJSON
        
        // Save (will update if exists, insert if new)
        _ = try await database.save(record)
        print("✅ Saved workout to CloudKit")
    }
    
    /// Delete a workout from CloudKit
    func deleteWorkout(_ workoutId: UUID) async throws {
        print("☁️ Deleting workout from CloudKit: \(workoutId)")
        
        let recordID = CKRecord.ID(recordName: workoutId.uuidString)
        
        do {
            _ = try await database.deleteRecord(withID: recordID)
            print("✅ Deleted workout from CloudKit")
        } catch {
            print("❌ CloudKit delete failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Template Operations
    
    /// Fetch all templates from CloudKit
    func fetchAllTemplates() async throws -> [WorkoutTemplate] {
        print("☁️ Fetching templates from CloudKit...")
        
        let query = CKQuery(
            recordType: templateRecordType,
            predicate: NSPredicate(value: true)
        )
        
        query.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        do {
            let (matchResults, _) = try await database.records(matching: query)
            
            var templates: [WorkoutTemplate] = []
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    if let template = convertRecordToTemplate(record) {
                        templates.append(template)
                    }
                case .failure(let error):
                    print("❌ Failed to fetch template: \(error)")
                }
            }
            
            print("✅ Fetched \(templates.count) templates from CloudKit")
            return templates
            
        } catch {
            print("❌ CloudKit template fetch failed: \(error)")
            throw error
        }
    }
    
    /// Save a template to CloudKit
    func saveTemplate(_ template: WorkoutTemplate) async throws {
        let recordID = CKRecord.ID(recordName: template.id.uuidString)
        
        // Try to fetch existing record first
        let record: CKRecord
        do {
            // If record exists, fetch it for updating
            record = try await database.record(for: recordID)
            print("📝 Updating existing template: \(template.name)")
        } catch {
            // If record doesn't exist, create new one
            record = CKRecord(recordType: templateRecordType, recordID: recordID)
            print("📝 Creating new template: \(template.name)")
        }
        
        // Set fields (same as before)
        record["name"] = template.name
        
        // Serialize exercises to JSON using helper method
        let exercisesJSON = convertTemplateExercisesToJSON(template.exercises)
        record["exercisesJSON"] = exercisesJSON
        
        // Save (will update if exists, insert if new)
        _ = try await database.save(record)
        print("✅ Saved template to CloudKit")
    }
    
    /// Delete a template from CloudKit
    func deleteTemplate(_ templateId: UUID) async throws {
        print("☁️ Deleting template from CloudKit: \(templateId)")
        
        let recordID = CKRecord.ID(recordName: templateId.uuidString)
        
        do {
            _ = try await database.deleteRecord(withID: recordID)
            print("✅ Deleted template from CloudKit")
        } catch {
            print("❌ CloudKit template delete failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Conversion: WorkoutSession ↔ CKRecord
    
    private func convertWorkoutToRecord(_ workout: WorkoutSession) -> CKRecord {
        let recordID = CKRecord.ID(recordName: workout.id.uuidString)
        let record = CKRecord(recordType: workoutRecordType, recordID: recordID)
        
        // Basic fields
        record["date"] = workout.date as CKRecordValue
        record["templateName"] = (workout.templateName ?? "") as CKRecordValue
        record["isCompleted"] = workout.isCompleted as CKRecordValue
        record["notes"] = (workout.notes ?? "") as CKRecordValue
        
        // Convert exercises to JSON
        let exercisesData = convertExercisesToJSON(workout.exercises)
        record["exercisesJSON"] = exercisesData as CKRecordValue
        
        return record
    }
    
    private func convertRecordToWorkout(_ record: CKRecord) -> WorkoutSession? {
        guard let date = record["date"] as? Date else {
            print("❌ Invalid workout record: missing date")
            return nil
        }
        
        let templateName = record["templateName"] as? String
        let isCompleted = record["isCompleted"] as? Bool ?? false
        let notes = record["notes"] as? String
        
        // Convert JSON back to exercises
        let exercisesJSON = record["exercisesJSON"] as? String ?? ""
        let exercises = convertJSONToExercises(exercisesJSON)
        
        let workout = WorkoutSession(
            templateName: templateName,
            date: date,
            exercises: exercises,
            isCompleted: isCompleted,
            notes: notes
        )
        
        // Set the ID from CloudKit record
        workout.id = UUID(uuidString: record.recordID.recordName) ?? workout.id
        
        return workout
    }
    
    // MARK: - Conversion: WorkoutTemplate ↔ CKRecord
    
    private func convertTemplateToRecord(_ template: WorkoutTemplate) -> CKRecord {
        let recordID = CKRecord.ID(recordName: template.id.uuidString)
        let record = CKRecord(recordType: templateRecordType, recordID: recordID)
        
        record["name"] = template.name as CKRecordValue
        
        // Convert exercises to JSON
        let exercisesData = convertTemplateExercisesToJSON(template.exercises)
        record["exercisesJSON"] = exercisesData as CKRecordValue
        
        return record
    }
    
    private func convertRecordToTemplate(_ record: CKRecord) -> WorkoutTemplate? {
        guard let name = record["name"] as? String else {
            print("❌ Invalid template record: missing name")
            return nil
        }
        
        let exercisesJSON = record["exercisesJSON"] as? String ?? ""
        let exercises = convertJSONToTemplateExercises(exercisesJSON)
        
        let template = WorkoutTemplate(name: name, exercises: exercises)
        template.id = UUID(uuidString: record.recordID.recordName) ?? template.id
        
        return template
    }
    
    // MARK: - JSON Conversion Helpers
    
    private func convertExercisesToJSON(_ exercises: [Exercise]) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        // Create a simpler structure for JSON
        let simpleExercises = exercises.map { exercise in
            [
                "id": exercise.id.uuidString,
                "name": exercise.name,
                "sets": exercise.sets.map { set in
                    [
                        "id": set.id.uuidString,
                        "weight": set.weight,
                        "reps": set.reps,
                        "isCompleted": set.isCompleted
                    ] as [String: Any]
                }
            ] as [String: Any]
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: simpleExercises),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "[]"
        }
        
        return jsonString
    }
    
    private func convertJSONToExercises(_ json: String) -> [Exercise] {
        guard let jsonData = json.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            return []
        }
        
        return array.compactMap { dict -> Exercise? in
            guard let name = dict["name"] as? String,
                  let setsArray = dict["sets"] as? [[String: Any]] else {
                return nil
            }
            
            let sets = setsArray.compactMap { setDict -> WorkoutSet? in
                guard let weight = setDict["weight"] as? Double,
                      let reps = setDict["reps"] as? Int,
                      let isCompleted = setDict["isCompleted"] as? Bool else {
                    return nil
                }
                
                return WorkoutSet(weight: weight, reps: reps, isCompleted: isCompleted)
            }
            
            return Exercise(name: name, sets: sets)
        }
    }
    
    private func convertTemplateExercisesToJSON(_ exercises: [TemplateExercise]) -> String {
        let encoder = JSONEncoder()
        
        let simpleExercises = exercises.map { exercise in
            [
                "id": exercise.id.uuidString,
                "name": exercise.name,
                "targetSets": exercise.targetSets,
                "targetRepsMin": exercise.targetRepsMin,
                "targetRepsMax": exercise.targetRepsMax,
                "notes": exercise.notes ?? ""
            ] as [String: Any]
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: simpleExercises),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "[]"
        }
        
        return jsonString
    }
    
    private func convertJSONToTemplateExercises(_ json: String) -> [TemplateExercise] {
        guard let jsonData = json.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            return []
        }
        
        return array.compactMap { dict -> TemplateExercise? in
            guard let name = dict["name"] as? String,
                  let targetSets = dict["targetSets"] as? Int,
                  let targetRepsMin = dict["targetRepsMin"] as? Int,
                  let targetRepsMax = dict["targetRepsMax"] as? Int else {
                return nil
            }
            
            let notes = dict["notes"] as? String
            
            return TemplateExercise(
                name: name,
                targetSets: targetSets,
                targetRepsMin: targetRepsMin,
                targetRepsMax: targetRepsMax,
                notes: notes?.isEmpty == false ? notes : nil
            )
        }
    }
}
