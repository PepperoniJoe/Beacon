//
//  Constants.swift
//  Beacon
//
//  Created by Marcy Vernon on 11/21/20.
//  Copyright © 2020 Marcy Vernon. All rights reserved.
//

import CoreLocation
import UIKit

//MARK: - Constants

struct K {
    
    ///Beacon Settings
    static let uuid = "AF80D50E-9905-4562-B154-AB5C82B635ED"
    static let beaconID = "Test Beacon"
    static let major: CLBeaconMajorValue = 500
    static let minor: CLBeaconMinorValue = 20
    
    /// Pulse Settings
    static let pulseAnimationKey = "pulse"
    static let opacity = "opacity"
    static let scaleXY = "transform.scale.xy"
    static let numPulse = 20
    static let radius: CGFloat = 450
    static let animationDuration: TimeInterval = 6
    static let backgroundColor = #colorLiteral(red: 0, green: 0.4470588235, blue: 0.5176470588, alpha: 0.4475157277).cgColor
    
}
