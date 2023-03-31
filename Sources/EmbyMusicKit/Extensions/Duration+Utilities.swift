//
//  Duration+Utilities.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 12/01/2023.
//

import Foundation
import SwiftCore

extension Duration {
    
    // MARK: - Functions
    
    static func microTicks<T: BinaryInteger>(_ value: T) -> Duration {
        .microseconds(value / 10)
    }
}
