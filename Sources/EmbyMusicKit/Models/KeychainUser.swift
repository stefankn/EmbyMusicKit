//
//  KeychainUser.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 28/01/2023.
//

import Foundation

struct KeychainUser: Codable {
    
    // MARK: - Properties
    
    let id: String
    let name: String
    let imageTag: String?
    
    
    
    // MARK: - Construction
    
    init(_ user: AuthenticatedUser) {
        id = user.id
        name = user.name
        imageTag = user.imageTag
    }
}
