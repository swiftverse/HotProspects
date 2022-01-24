//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Amit Shrivastava on 22/01/22.
//

import SwiftUI
import CodeScanner


enum FilterType {
    case none
    case contacted
    case notContacted
}





struct ProspectsView: View {
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    var filter: FilterType
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
  
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) {
                    item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.email)
                            .foregroundColor(.secondary)
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
                        }
                    }
                }
            }
                .navigationTitle(result)
                .toolbar {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }

                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)

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
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
