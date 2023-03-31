//
//  ConfigService.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation
import SwiftCore

public final class ConfigService {
    
    // MARK: - Private Properties
    
    private let keychain: Keychain
    
    

    // MARK: - Properties
    
    public var host: String? {
        get { UserDefaults.standard.string(for: .embyHost) }
        set { UserDefaults.standard.set(newValue, for: .embyHost) }
    }
    
    public var user: AuthenticatedUser? {
        get {
            if
                let data = UserDefaults.standard.data(for: .embyUser),
                let user = try? JSONDecoder().decode(KeychainUser.self, from: data),
                let accessToken = keychain.string(for: user.id) {

                return AuthenticatedUser(user, accessToken: accessToken)
            } else {
                return nil
            }
        }
        set {
            if let user = newValue, keychain.set(user.accessToken, for: user.id) {
                UserDefaults.standard.set(try? JSONEncoder().encode(KeychainUser(user)), for: .embyUser)
            } else {
                if
                    let data = UserDefaults.standard.data(for: .embyUser),
                    let user = try? JSONDecoder().decode(KeychainUser.self, from: data) {
                    
                    _ = keychain.remove(for: user.id)
                }
                UserDefaults.standard.remove(for: .embyUser)
            }
        }
    }
    
    
    
    // MARK: - Construction
    
    public init(keychain: Keychain) {
        self.keychain = keychain
    }
    
}
