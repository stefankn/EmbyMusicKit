//
//  AuthenticatedUser.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

public struct AuthenticatedUser {
    
    // MARK: - Properties
    
    public let id: String
    public let name: String
    public let accessToken: String
    public let imageTag: String?
    
    
    
    // MARK: - Construction
    
    init(_ response: AuthenticationResponse) {
        id = response.id
        name = response.name
        imageTag = response.imageTag
        accessToken = response.accessToken
    }
    
    init(_ user: KeychainUser, accessToken: String) {
        id = user.id
        name = user.name
        imageTag = user.imageTag
        self.accessToken = accessToken
    }
}
