//
//  User.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

public struct User: Decodable, Identifiable, Equatable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case isPasswordRequired = "HasPassword"
        case isPasswordConfigured = "HasConfiguredPassword"
        case isPincodeConfigured = "HasConfiguredEasyPassword"
        case imageTag = "PrimaryImageTag"
    }
    
    
    
    // MARK: - Properties
    
    public let id: String
    public let name: String
    public let isPasswordConfigured: Bool
    public let isPincodeConfigured: Bool
    public let imageTag: String?
    public let isPasswordRequired: Bool
    
    
    
    // MARK: - Construction
    
    public init(id: String, name: String, isPasswordConfigured: Bool, isPincodeConfigured: Bool, imageTag: String?, isPasswordRequired: Bool) {
        self.id = id
        self.name = name
        self.isPasswordConfigured = isPasswordConfigured
        self.isPincodeConfigured = isPincodeConfigured
        self.imageTag = imageTag
        self.isPasswordRequired = isPasswordRequired
    }
}
