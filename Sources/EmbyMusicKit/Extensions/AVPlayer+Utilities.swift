//
//  AVPlayer+Utilities.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 12/01/2023.
//

import Foundation
import AVFoundation

extension AVPlayer {
    
    // MARK: - Properties
    
    var currentTimeDuration: Duration {
        Duration.seconds(currentTime().seconds)
    }
    
    
    
    // MARK: - Functions
    
    func seek(to duration: Duration, completion: ((Bool) -> Void)? = nil) {
        let time = CMTime(seconds: duration.seconds, preferredTimescale: 60000)
        
        if let completion = completion {
            seek(to: time, completionHandler: completion)
        } else {
            seek(to: time)
        }
    }
}
