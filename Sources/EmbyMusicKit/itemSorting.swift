//
//  ItemSorting.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 10/02/2023.
//

import Foundation
import SwiftCore

public struct ItemSorting: Hashable, Identifiable, CaseIterable, Codable {
    
    // MARK: - Constants
    
    public static var albumKeys: [ItemSorting.Key] {
        [.name, .added, .productionYear]
    }
    
    
    // MARK: CaseIterable Constants
    
    public static var allCases: [ItemSorting] {
        cases(for: Key.allCases)
    }
    
    
    
    // MARK: - Properties
    
    public let key: Key
    public let order: Order
    
    public var title: String {
        key.title
    }
    
    public var systemImage: String {
        order.systemImage
    }
    
    var parameters: Service.Parameters {
        [
            ("SortBy", key.rawValue),
            ("SortOrder", order.rawValue)
        ]
    }
    
    
    // MARK: Identifiable Properties
    
    public var id: String {
        key.rawValue + order.rawValue
    }
    
    
    
    // MARK: - Construction
    
    public init(key: Key, order: Order) {
        self.key = key
        self.order = order
    }
    
    
    
    // MARK: - Functions
    
    public static func name(_ order: Order) -> ItemSorting {
        ItemSorting(key: .name, order: order)
    }
    
    public static func index(_ order: Order) -> ItemSorting {
        ItemSorting(key: .index, order: order)
    }
    
    public static func productionYear(_ order: Order) -> ItemSorting {
        ItemSorting(key: .index, order: order)
    }
    
    public static func playCount(_ order: Order) -> ItemSorting {
        ItemSorting(key: .playCount, order: order)
    }
    
    public static func listItem(_ order: Order) -> ItemSorting {
        ItemSorting(key: .listItem, order: order)
    }
    
    
    
    // MARK: - Private Functions
    
    private static func cases(for keys: Key...) -> [ItemSorting] {
        cases(for: keys)
    }
    
    private static func cases(for keys: [Key]) -> [ItemSorting] {
        keys.flatMap{ key in Order.allCases.map{ ItemSorting(key: key, order: $0) } }
    }
    
}
