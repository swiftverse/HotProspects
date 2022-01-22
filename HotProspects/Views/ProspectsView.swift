//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Amit Shrivastava on 22/01/22.
//

import SwiftUI


enum FilterType {
    case none
    case contacted
    case notContacted
}





struct ProspectsView: View {
    @EnvironmentObject var prospects: Prospects

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
                }
            }
                .navigationTitle(result)
                .toolbar {
                    Button {
                        let prospect = Prospect()
                        prospect.name = "DareDance"
                        prospect.email = "daredance@email.com"
                        prospect.isContacted = true
                        prospects.people.append(prospect)
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
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
