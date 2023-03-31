//
//  AuthenticationRequest.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

struct AuthenticationRequest: Encodable {
    
    // MARK: - Properties
    
    let password: String?
    let pw: String?
    
    
    
    // MARK: - Construction
    
    init(password: String?) {
        self.password = password
        pw = password
    }
}
