//
//  WorkoutRepository.swift
//  uplift
//
//  Created by Ruitao Chen on 12/15/25.
//

import Foundation
import SwiftData

/// Main repository implementation
/// Coordinates between local, cloud, and sync engine
class WorkoutRepository: WorkoutRepositoryProtocol {
    
    // MARK: - Properties
    
    private let localDataSource: LocalDataSource
    private let cloudDataSource: CloudDataSource      // ✅ NEW
    private let syncEngine: SyncEngine                // ✅ NEW
    
    // MARK: - Initialization
    
    init(
        modelContext: ModelContext,
        cloudDataSource: CloudDataSource,             // ✅ NEW
        syncEngine: SyncEngine                        // ✅ NEW
    ) {
        self.localDataSource = LocalDataSource(modelContext: modelContext)
        self.cloudDataSource = cloudDataSource
        self.syncEngine = syncEngine
    }
    
    // MARK: - Workout Operations
    
    func fetchWorkouts() async -> [WorkoutSession] {
        print("📊 Fetching workouts from all sources...")
        
        // 1. Get local workouts (fast)
        let localWorkouts = localDataSource.fetchAllWorkouts()
        print("📱 Local: \(localWorkouts.count) workouts")
        
        // 2. Try to get cloud workouts (might fail if offline)
        var cloudWorkouts: [WorkoutSession] = []
        do {
            cloudWorkouts = try await cloudDataSource.fetchAllWorkouts()
            print("☁️ Cloud: \(cloudWorkouts.count) workouts")
        } catch {
            print("⚠️ Cloud fetch failed (offline?): \(error.localizedDescription)")
            // Continue with local data only
        }
        
        // 3. Merge local + cloud
        let mergedWorkouts = syncEngine.mergeWorkouts(
            local: localWorkouts,
            cloud: cloudWorkouts
        )
        
        // 4. Background: Upload any local-only workouts
        Task {
            await uploadMissingWorkouts(local: localWorkouts, cloud: cloudWorkouts)
        }
        
        // 5. Background: Download any cloud-only workouts
        Task {
            await downloadMissingWorkouts(local: localWorkouts, cloud: cloudWorkouts)
        }
        
        return mergedWorkouts
    }
    
    func save(_ workout: WorkoutSession) async throws {
        print("💾 Saving workout: \(workout.templateName ?? "Workout")")
        
        // 1. Save to local database (fast, always works)
        try localDataSource.saveWorkout(workout)
        print("✅ Saved locally")
        
        // 2. Upload to cloud (slower, might fail)
        Task {
            do {
                try await cloudDataSource.saveWorkout(workout)
                print("✅ Uploaded to cloud")
            } catch {
                print("⚠️ Cloud upload failed: \(error.localizedDescription)")
                // Local save succeeded, cloud will sync later
            }
        }
    }
    
    func delete(_ workout: WorkoutSession) async throws {
        print("🗑️ Deleting workout: \(workout.templateName ?? "Workout")")
        
        // 1. Delete from local database
        try localDataSource.deleteWorkout(workout)
        print("✅ Deleted locally")
        
        // 2. Delete from cloud
        Task {
            do {
                try await cloudDataSource.deleteWorkout(workout.id)
                print("✅ Deleted from cloud")
            } catch {
                print("⚠️ Cloud delete failed: \(error.localizedDescription)")
                // Local delete succeeded, cloud will sync later
            }
        }
    }
    
    // MARK: - Template Operations
    
    func fetchTemplates() async -> [WorkoutTemplate] {
        print("📊 Fetching templates from all sources...")
        
        // 1. Get local templates
        let localTemplates = localDataSource.fetchAllTemplates()
        print("📱 Local: \(localTemplates.count) templates")
        
        // 2. Try to get cloud templates
        var cloudTemplates: [WorkoutTemplate] = []
        do {
            cloudTemplates = try await cloudDataSource.fetchAllTemplates()
            print("☁️ Cloud: \(cloudTemplates.count) templates")
        } catch {
            print("⚠️ Cloud fetch failed: \(error.localizedDescription)")
        }
        
        // 3. Merge
        let mergedTemplates = syncEngine.mergeTemplates(
            local: localTemplates,
            cloud: cloudTemplates
        )
        
        // 4. Background sync
        Task {
            await uploadMissingTemplates(local: localTemplates, cloud: cloudTemplates)
        }
        
        Task {
            await downloadMissingTemplates(local: localTemplates, cloud: cloudTemplates)
        }
        
        return mergedTemplates
    }
    
    func save(_ template: WorkoutTemplate) async throws {
        print("💾 Saving template: \(template.name)")
        
        // 1. Save locally
        try localDataSource.saveTemplate(template)
        print("✅ Saved locally")
        
        // 2. Upload to cloud
        Task {
            do {
                try await cloudDataSource.saveTemplate(template)
                print("✅ Uploaded to cloud")
            } catch {
                print("⚠️ Cloud upload failed: \(error.localizedDescription)")
            }
        }
    }
    
    func delete(_ template: WorkoutTemplate) async throws {
        print("🗑️ Deleting template: \(template.name)")
        
        // 1. Delete locally
        try localDataSource.deleteTemplate(template)
        print("✅ Deleted locally")
        
        // 2. Delete from cloud
        Task {
            do {
                try await cloudDataSource.deleteTemplate(template.id)
                print("✅ Deleted from cloud")
            } catch {
                print("⚠️ Cloud delete failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Background Sync Helpers
    
    private func uploadMissingWorkouts(local: [WorkoutSession], cloud: [WorkoutSession]) async {
        let toUpload = syncEngine.findWorkoutsToUpload(local: local, cloud: cloud)
        
        for workout in toUpload {
            do {
                try await cloudDataSource.saveWorkout(workout)
                print("📤 Uploaded: \(workout.templateName ?? "Workout")")
            } catch {
                print("❌ Upload failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func downloadMissingWorkouts(local: [WorkoutSession], cloud: [WorkoutSession]) async {
        let toDownload = syncEngine.findWorkoutsToDownload(local: local, cloud: cloud)
        
        for workout in toDownload {
            do {
                try localDataSource.saveWorkout(workout)
                print("📥 Downloaded: \(workout.templateName ?? "Workout")")
            } catch {
                print("❌ Download failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func uploadMissingTemplates(local: [WorkoutTemplate], cloud: [WorkoutTemplate]) async {
        let toUpload = syncEngine.findTemplatesToUpload(local: local, cloud: cloud)
        
        for template in toUpload {
            do {
                try await cloudDataSource.saveTemplate(template)
                print("📤 Uploaded template: \(template.name)")
            } catch {
                print("❌ Upload failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func downloadMissingTemplates(local: [WorkoutTemplate], cloud: [WorkoutTemplate]) async {
        let toDownload = syncEngine.findTemplatesToDownload(local: local, cloud: cloud)
        
        for template in toDownload {
            do {
                try localDataSource.saveTemplate(template)
                print("📥 Downloaded template: \(template.name)")
            } catch {
                print("❌ Download failed: \(error.localizedDescription)")
            }
        }
    }
}
