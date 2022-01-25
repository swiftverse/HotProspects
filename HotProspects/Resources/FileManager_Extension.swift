//
//  FileManager_Extension.swift
//  HotProspects
//
//  Created by Amit Shrivastava on 25/01/22.
//

import Foundation


extension FileManager {
    static var getDocumentsDirectory: URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
}
