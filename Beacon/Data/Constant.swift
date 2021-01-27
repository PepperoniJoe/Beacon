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
    ///App Settings
    static let defaultColor  = "DefaultColor"
    static let defaultColor2 = "DefaultColor2"
    static let emptyString   = ""
    
    ///Beacon Settings
    static let uuid                       = "AF80D50E-9905-4562-B154-AB5C82B635ED"
    static let beaconID                   = "Flexible iOS Beacon"
    static let major : CLBeaconMajorValue = 1
    static let minor : CLBeaconMinorValue = 1
    
    ///User Interface
    static let imageBeaconBall = "BeaconBall"
    
    ///Alert Settings
    static let alert          = "Alert"
    static let titleTextColor = "titleTextColor"
    static let ok             = "OK"
    
    ///Alert Messages
    static let noBluetooth = "This device does not have bluetooth powered on."
    static let noBluetoothSupport = "The device running this app does not support bluetooth."
    static let simulator = "Unfortunately simulators lack bluetooth capabilities needed to act as a bluetooth beacon. Please use this app on an iOS device with bluetooth."
    
    /// Pulse Settings
    static let transmitting      = "Transmitting"
    static let nothing           = ""
    static let pulseAnimationKey = "pulse"
    static let opacity           = "opacity"
    static let scaleXY           = "transform.scale.xy"
    static let numPulse          = 10
    static let radius : CGFloat  = 300
    static let animationDuration : TimeInterval = 6
}


