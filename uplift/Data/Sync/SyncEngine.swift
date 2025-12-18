//
//  SyncEngine.swift
//  uplift
//
//  Created by Ruitao Chen on 12/18/25.
//

import Foundation

/// Merges local and cloud data intelligently
/// Handles conflict resolution and sync logic
class SyncEngine {
    
    // MARK: - Merge Workouts
    
    /// Merge local and cloud workouts
    /// Strategy: Use the most recently modified version
    func mergeWorkouts(local: [WorkoutSession], cloud: [WorkoutSession]) -> [WorkoutSession] {
        print("🔄 Merging workouts - Local: \(local.count), Cloud: \(cloud.count)")
        
        var merged: [UUID: WorkoutSession] = [:]
        
        // Add all local workouts first
        for workout in local {
            merged[workout.id] = workout
        }
        
        // Process cloud workouts
        for cloudWorkout in cloud {
            if let localWorkout = merged[cloudWorkout.id] {
                // Workout exists in both - use the newer one
                // Compare by date (most recent workout date wins)
                if cloudWorkout.date > localWorkout.date {
                    print("☁️ Cloud version newer for: \(cloudWorkout.templateName ?? "Workout")")
                    merged[cloudWorkout.id] = cloudWorkout
                } else {
                    print("📱 Local version newer for: \(localWorkout.templateName ?? "Workout")")
                    // Keep local version (already in merged)
                }
            } else {
                // Workout only exists in cloud - add it
                print("☁️ Adding cloud-only workout: \(cloudWorkout.templateName ?? "Workout")")
                merged[cloudWorkout.id] = cloudWorkout
            }
        }
        
        let result = Array(merged.values).sorted { $0.date > $1.date }
        print("✅ Merge complete - Total: \(result.count) workouts")
        
        return result
    }
    
    // MARK: - Merge Templates
    
    /// Merge local and cloud templates
    /// Strategy: Cloud wins (templates are less frequently modified)
    func mergeTemplates(local: [WorkoutTemplate], cloud: [WorkoutTemplate]) -> [WorkoutTemplate] {
        print("🔄 Merging templates - Local: \(local.count), Cloud: \(cloud.count)")
        
        var merged: [UUID: WorkoutTemplate] = [:]
        
        // Add all local templates first
        for template in local {
            merged[template.id] = template
        }
        
        // Cloud templates override local (simpler strategy for templates)
        for cloudTemplate in cloud {
            if merged[cloudTemplate.id] != nil {
                print("☁️ Cloud template overriding local: \(cloudTemplate.name)")
            } else {
                print("☁️ Adding cloud-only template: \(cloudTemplate.name)")
            }
            merged[cloudTemplate.id] = cloudTemplate
        }
        
        let result = Array(merged.values).sorted { $0.name < $1.name }
        print("✅ Merge complete - Total: \(result.count) templates")
        
        return result
    }
    
    // MARK: - Identify Items to Upload
    
    /// Find workouts that exist locally but not in cloud
    func findWorkoutsToUpload(local: [WorkoutSession], cloud: [WorkoutSession]) -> [WorkoutSession] {
        let cloudIDs = Set(cloud.map { $0.id })
        let toUpload = local.filter { !cloudIDs.contains($0.id) }
        
        if !toUpload.isEmpty {
            print("📤 Found \(toUpload.count) workouts to upload")
        }
        
        return toUpload
    }
    
    /// Find templates that exist locally but not in cloud
    func findTemplatesToUpload(local: [WorkoutTemplate], cloud: [WorkoutTemplate]) -> [WorkoutTemplate] {
        let cloudIDs = Set(cloud.map { $0.id })
        let toUpload = local.filter { !cloudIDs.contains($0.id) }
        
        if !toUpload.isEmpty {
            print("📤 Found \(toUpload.count) templates to upload")
        }
        
        return toUpload
    }
    
    // MARK: - Identify Items to Download
    
    /// Find workouts that exist in cloud but not locally
    func findWorkoutsToDownload(local: [WorkoutSession], cloud: [WorkoutSession]) -> [WorkoutSession] {
        let localIDs = Set(local.map { $0.id })
        let toDownload = cloud.filter { !localIDs.contains($0.id) }
        
        if !toDownload.isEmpty {
            print("📥 Found \(toDownload.count) workouts to download")
        }
        
        return toDownload
    }
    
    /// Find templates that exist in cloud but not locally
    func findTemplatesToDownload(local: [WorkoutTemplate], cloud: [WorkoutTemplate]) -> [WorkoutTemplate] {
        let localIDs = Set(local.map { $0.id })
        let toDownload = cloud.filter { !localIDs.contains($0.id) }
        
        if !toDownload.isEmpty {
            print("📥 Found \(toDownload.count) templates to download")
        }
        
        return toDownload
    }
}
