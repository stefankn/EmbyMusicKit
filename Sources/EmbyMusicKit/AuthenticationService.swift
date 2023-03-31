//
//  AuthenticationService.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 15/01/2023.
//

import UIKit
import SwiftCore

public final class AuthenticationService: Service {
    
    // MARK: - Properties
    
    let host: String
    
    
    // MARK: Service Properties
    
    public override var baseURL: URL? {
        URL("http://\(host)")
    }
    
    public override var configuration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return configuration
    }
    
    
    // MARK: - Construction
    
    public init(host: String) {
        self.host = host
    }
    
    
    
    // MARK: - Functions
    
    public func systemInfo() async throws -> SystemInfo {
        try await get("/emby/System/Info/Public")
    }
    
    public func publicUsers() async throws -> [User] {
        try await get("/emby/Users/Public")
    }
    
    public func authenticate(userId: String, password: String?) async throws -> AuthenticatedUser {
        let url = try url(for: "/emby/Users/\(userId)/Authenticate")
        var request = URLRequest(method: .post, url: url)
        addClientIdentificationHeaders(for: &request)
        
        let response: AuthenticationResponse = try await self.request(request, body: AuthenticationRequest(password: password))
        
        return AuthenticatedUser(response)
    }
    
    public func authenticateByName(_ name: String, password: String) async throws -> AuthenticatedUser {
        let url = try url(for: "/emby/Users/AuthenticateByName")
        
        var request = URLRequest(method: .post, url: url)
        addClientIdentificationHeaders(for: &request)
        
        let response: AuthenticationResponse = try await self.request(request, body: AuthenticationUsernameRequest(username: name, password: password))
        
        return AuthenticatedUser(response)
    }
    
    public func imageURL(for user: User) -> URL? {
        if let imageTag = user.imageTag {
            return URL(string: "/emby/Users/\(user.id)/images/Primary?maxHeight=400&maxWidth=400&tag=\(imageTag)", relativeTo: baseURL)
        } else {
            return nil
        }
    }
    
    
    
    // MARK: - Private Functions
    
    private func addClientIdentificationHeaders(for request: inout URLRequest) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        request.setValue("Linnet", forHTTPHeaderField: "X-Emby-Client")
        request.setValue(UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone", forHTTPHeaderField: "X-Emby-Device-Name")
        request.setValue(UIDevice.current.identifierForVendor?.uuidString, forHTTPHeaderField: "X-Emby-Device-Id")
        request.setValue(version, forHTTPHeaderField: "X-Emby-Client-Version")
    }
}
 
