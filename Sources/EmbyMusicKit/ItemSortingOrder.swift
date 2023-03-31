//
//  ItemSortingOrder.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 10/02/2023.
//

import Foundation

extension ItemSorting {
    public enum Order: String, CaseIterable, Codable {
        case ascending = "Ascending"
        case descending = "Descending"
        
        
        
        // MARK: - Properties
        
        public var systemImage: String {
            switch self {
            case .ascending:
                return "arrow.up"
            case .descending:
                return "arrow.down"
            }
        }
    }
}
