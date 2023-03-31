//
//  AuthenticationUsernameRequest.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 20/01/2023.
//

import Foundation

struct AuthenticationUsernameRequest: Encodable {
    
    // MARK: - Properties
    
    let username: String
    let password: String
    let pw: String
    
    
    
    // MARK: - Construction
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        pw = password
    }
}
