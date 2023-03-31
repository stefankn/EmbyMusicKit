//
//  ExternalURL.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 03/02/2023.
//

import Foundation

public struct ExternalURL: Decodable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case _url = "Url"
        case name = "Name"
    }
    
    
    
    // MARK: - Private Properties
    
    private let _url: String
    
    
    
    // MARK: - Properties
    
    public let name: String
    
    public var url: URL? {
        URL(_url)
    }
}
