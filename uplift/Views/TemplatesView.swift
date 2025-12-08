//
//  TemplatesView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var favoriteTemplateIds: Set<UUID> = []
    @State private var showingCreateTemplate = false
    @State private var templateToEdit: WorkoutTemplate?
    
    private var favoriteTemplates: [WorkoutTemplate] {
        workoutManager.templates.filter { favoriteTemplateIds.contains($0.id) }
    }

    private var otherTemplates: [WorkoutTemplate] {
        workoutManager.templates.filter { !favoriteTemplateIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    headerView
                    
                    if workoutManager.templates.isEmpty {
                        // Empty State
                        emptyStateView
                    } else {
                        // Template List
                        ScrollView {
                            VStack(spacing: 24) {
                                // Favorites Section
                                if !favoriteTemplates.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Favorites")
                                            .font(.futuraTitle3())
                                            .foregroundColor(.white)
                                            .padding(.horizontal)
                                        
                                        ForEach(favoriteTemplates) { template in
                                            TemplateCard(
                                                template: template,
                                                isFavorite: true,
                                                onTap: {
                                                    templateToEdit = template
                                                },
                                                onToggleFavorite: {
                                                    toggleFavorite(template)
                                                },
                                                onDelete: {
                                                    deleteTemplate(template)
                                                }
                                            )
                                        }
                                    }
                                }
                                
                                // All Templates Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(favoriteTemplates.isEmpty ? "Templates" : "All Templates")
                                        .font(.futuraHeadline())
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    ForEach(otherTemplates) { template in
                                        TemplateCard(
                                            template: template,
                                            isFavorite: false,
                                            onTap: {
                                                templateToEdit = template
                                            },
                                            onToggleFavorite: {
                                                toggleFavorite(template)
                                            },
                                            onDelete: {
                                                deleteTemplate(template)
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateTemplate) {
                CreateEditTemplateView(
                    template: nil,
                    onSave: { newTemplate in
                        workoutManager.addTemplate(newTemplate)
                    }
                )
            }
            .sheet(item: $templateToEdit) { template in
                if let index = workoutManager.templates.firstIndex(where: { $0.id == template.id }) {
                    CreateEditTemplateView(
                        template: workoutManager.templates[index],
                        onSave: { updatedTemplate in
                            let original = workoutManager.templates[index]
                            original.name = updatedTemplate.name
                            original.exercises = updatedTemplate.exercises
                            workoutManager.updateTemplate(original)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var headerView: some View {
        HStack(spacing: 16) {
            // User initials circle on the left
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                
                Text("RC")  // User initials
                    .font(.futuraHeadline())
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Centered "Templates" text
            Text("Templates")
                .font(.futuraTitle2())
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            // Add button on the right
            Button(action: {
                showingCreateTemplate = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.clipboard.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Templates Yet")
                    .font(.futuraTitle2())
                    .foregroundColor(.white)
                
                Text("Create your first workout template to get started")
                    .font(.futuraBody())
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingCreateTemplate = true
            }) {
                Text("Create Your First Template")
                    .font(.futuraHeadline())
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                    .fadeEdgeBorder(
                        color: .white.opacity(0.6),
                        cornerRadius: 12,
                        lineWidth: 1,
                        fadeStyle: .radial
                    )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func toggleFavorite(_ template: WorkoutTemplate) {
        if favoriteTemplateIds.contains(template.id) {
            favoriteTemplateIds.remove(template.id)
        } else {
            favoriteTemplateIds.insert(template.id)
        }
    }
    
    private func deleteTemplate(_ template: WorkoutTemplate) {
        workoutManager.deleteTemplate(template)
        favoriteTemplateIds.remove(template.id)
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: WorkoutTemplate
    let isFavorite: Bool
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Favorite Star
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .gray)
                        .font(.futuraTitle3())
                }
                .buttonStyle(PlainButtonStyle())
                
                // Template Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text("\(template.totalExercises) exercises")
                        .font(.futuraSubheadline())
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.futuraSubheadline())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
            )
            .fadeEdgeBorder(
                color: .white.opacity(0.5),
                cornerRadius: 16,
                lineWidth: 1,
                fadeStyle: .radial
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: onToggleFavorite) {
                Label(isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: isFavorite ? "star.slash" : "star.fill")
            }
            
            Button(role: .destructive, action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete Template", systemImage: "trash")
            }
        }
        .alert("Delete Template?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("This will permanently delete \"\(template.name)\" and cannot be undone.")
        }
    }
}
