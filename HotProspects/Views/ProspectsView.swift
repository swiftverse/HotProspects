//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Amit Shrivastava on 22/01/22.
//

import SwiftUI
import CodeScanner
import UserNotifications

enum FilterType {
    case none
    case contacted
    case notContacted
}

enum SortData {
    case byName
    case byDate
}



struct ProspectsView: View {
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var sortIsActive = false
    var filter: FilterType
    @State var sort = SortData.byDate
    var result: String {
        switch filter {
        case .none:
            return "All prospects"
        case .notContacted:
            return "Not Contacted"
        case .contacted:
            return "Contacted"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .notContacted:
            return prospects.people.filter{ $0.isContacted == false }
        case .contacted:
            return prospects.people.filter { $0.isContacted != false
            }
        }
        
    }
    
    
    
    var sortedProspect: [Prospect] {
        switch sort {
        case .byName:
            return filteredProspects.sorted()
        case .byDate:
            return filteredProspects.sorted { lhs, rhs in
                if  lhs.dateAdded != rhs.dateAdded {
                    return lhs.dateAdded < rhs.dateAdded
                } else { return lhs.id < rhs.id }
            }
                    
        }
    }
    
    
  
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedProspect) {
                    item in
                    HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.email)
                            .foregroundColor(.secondary)
                    }
                        Spacer()
                        Image(systemName: item.isContacted ? "person.fill.checkmark" : "person.fill.xmark")
                    }
                
                    .swipeActions {
                        if item.isContacted {
                            Button {
                                prospects.toggle(item)
                            }
                        label: {
                            Label("Mark uncontacted", systemImage: "person.crop.circle.badge.xmark")
                        }
                        .tint(.blue)
                        }
                        
                        else {
                            Button {
                                prospects.toggle(item)
                            }
                        label: {
                            Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")

                        }
                        .tint(.green)
                            
                            Button {
                                addNotification(for: item)
                            } label: {
                                Label("Remind Me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
                
            }
            
                .navigationTitle(result)
                .toolbar {
//                    Button {
//                        isShowingScanner = true
//                    } label: {
//                        Image(systemName: "qrcode.viewfinder")
//                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingScanner = true
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            sortIsActive = true
                        } label: {
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                        }
                    }

                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)

                    }
                
        }
        .confirmationDialog("Choose Sort", isPresented: $sortIsActive) {
            Button("Sort Names") {
                print("names sort")
                sort = .byName
            }
            
            Button("Sort Recent") {
                sort = .byDate
                
            }
        }
        
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.email = details[1]
            prospects.add(person)
            
        case .failure(let error):
            print("Scanning failed : \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.email
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            
           // let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                            if success {
                                addRequest()
                            } else {
                                print("D'oh")
                            }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
