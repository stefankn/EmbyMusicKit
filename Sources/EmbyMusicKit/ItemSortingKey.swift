//
//  ItemSortingKey.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 10/02/2023.
//

import Foundation

extension ItemSorting {
    public enum Key: String, CaseIterable, Codable {
        case name = "SortName"
        case index = "SortIndexNumber"
        case productionYear = "ProductionYear"
        case added = "DateCreated"
        case playCount = "PlayCount"
        case listItem = "ListItemOrder"
        
        
        
        // MARK: - Properties
        
        public var title: String {
            switch self {
            case .name:
                return "Title"
            case .index:
                return "Number"
            case .productionYear:
                return "Release date"
            case .added:
                return "Date added"
            case .playCount:
                return "Times played"
            case .listItem:
                return "Custom"
            }
        }
        
        public var isIndexable: Bool {
            self == .name
        }
    }
}
