//
//  AuthenticationResponse.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

struct AuthenticationResponse: Decodable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "AccessToken"
        case user = "User"
    }
    
    enum UserCodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case imageTag = "PrimaryImageTag"
    }
    
    
    
    // MARK: - Properties
    
    let id: String
    let name: String
    let imageTag: String?
    let accessToken: String
    
    
    
    // MARK: - Construction
    
    // MARK: Decodable Construction
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        
        let userContainer = try container.nestedContainer(keyedBy: UserCodingKeys.self, forKey: .user)
        id = try userContainer.decode(String.self, forKey: .id)
        name = try userContainer.decode(String.self, forKey: .name)
        imageTag = try userContainer.decodeIfPresent(String.self, forKey: .imageTag)
    }
}
