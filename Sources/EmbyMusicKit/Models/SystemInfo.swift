//
//  SystemInfo.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

public struct SystemInfo: Decodable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case serverName = "ServerName"
        case version = "Version"
        case operatingSystem = "OperatingSystem"
        case isUpdateAvailable = "HasUpdateAvailable"
    }
    
    
    
    // MARK: - Properties
    
    public let serverName: String
    public let version: String
    public let operatingSystem: String?
    public let isUpdateAvailable: Bool?
}
