//
//  SearchView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/24/25.
//

import SwiftUI

struct SearchView: View {
    @State var showingSearchSheet = true
    
    var body: some View {
        VStack {
            Button("Find an Event") {
                showingSearchSheet.toggle()
            }
        }
        .sheet(isPresented: $showingSearchSheet) {
            SearchSheetView()
        }
    }
}

#Preview {
    SearchView()
}

struct SearchSheetView: View {
    private enum EventTypes: String, CaseIterable, Identifiable {
        case concert = "Concert"
        case comedy = "Comedy Show"
        case sportsGame = "Sports Game"
        case arts = "Arts & Crafts"
        case cooking = "Cooking Classes"
        case park = "Park"
        case happyHour = "Happy Hour"
        
        var id: String { self.rawValue }
    }
    
    @State private var groupSize = 2
    @State private var selectedEventTypes: Set<EventTypes> = []
    
    @State private var isEventTypesExpanded = false
    
    var body: some View {
        Form {
            Stepper("Group Size: \(groupSize)\(groupSize == 10 ? "+" : "")", value: $groupSize, in: 2...10, step: 1)
            DisclosureGroup(
                isExpanded: $isEventTypesExpanded,
                content: {
                    ForEach(EventTypes.allCases) { eventType in
                        Button(action: {
                            if selectedEventTypes.contains(eventType) {
                                selectedEventTypes.remove(eventType)
                            } else {
                                selectedEventTypes.insert(eventType)
                            }
                        }) {
                            HStack {
                                Text(eventType.rawValue)
                                Spacer()
                                if selectedEventTypes.contains(eventType) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                },
                label: {
                    HStack {
                        Text("Event Types")
                        Spacer()
                        if !selectedEventTypes.isEmpty {
                            Text("\(selectedEventTypes.count) selected")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
                }
            )
            
            // Optional: Display selected event types below
            if !selectedEventTypes.isEmpty {
                Section(header: Text("Selected Events")) {
                    Text(selectedEventTypesText)
                }
            }
        }
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
    }
    
    private var selectedEventTypesText: String {
        selectedEventTypes.map { $0.rawValue }.joined(separator: ", ")
    }
}
