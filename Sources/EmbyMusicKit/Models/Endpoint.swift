//
//  Endpoint.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 03/03/2023.
//

import Foundation

public struct Endpoint: Decodable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case isLocal = "IsLocal"
        case isInNetwork = "IsInNetwork"
    }
    
    
    
    // MARK: - Properties
    
    public let isLocal: Bool
    public let isInNetwork: Bool
}
