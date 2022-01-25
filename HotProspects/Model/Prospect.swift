//
//  Prospect.swift
//  HotProspects
//
//  Created by Amit Shrivastava on 22/01/22.
//

import SwiftUI


class Prospect: Identifiable, Codable, Comparable {
    static func < (lhs: Prospect, rhs: Prospect) -> Bool {
        if lhs.name != rhs.name {
            return lhs.name < rhs.name
        } else {
            return lhs.id < rhs.id
        }
    }
    
    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    var name = "anonymous"
    var email = ""
    fileprivate(set) var isContacted = false
    var dateAdded = Date()
}

@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    let saveKey = "SavedData"
    let savePath = FileManager.getDocumentsDirectory.appendingPathComponent("SavedData")
    init() {
        
//        if let data = UserDefaults.standard.data(forKey: saveKey) {
//            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
//                people = decoded
//                return
//            }
//        }
        
        if let data = try? Data(contentsOf: savePath) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }
        people = []
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    private func save() {
//        if let encoded = try? JSONEncoder().encode(people) {
//            UserDefaults.standard.set(encoded, forKey: saveKey)
//        }
        do {
            let data = try? JSONEncoder().encode(people)
            try data?.write(to: savePath, options: [.atomic, .completeFileProtection])
        }
        
        catch {
            print("unable to save data")
        }
        
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
}
