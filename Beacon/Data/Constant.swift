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
    //  Nothing special about these values. Just set these values to match your iBeacon-detecting app.
    // The mac's Terminal app can be used to generate a unique UUID. Command is uuidgen
    static let uuid                       = "AF80D50E-9905-4562-B154-AB5C82B635ED"  // generated using uuidgen
    static let beaconID                   = "Flexible iOS Beacon"  // any string
    static let major : CLBeaconMajorValue = 1 // any unsigned integer (UInt16)
    static let minor : CLBeaconMinorValue = 1 // any unsigned integer (UInt16)
    
    ///App-wide Settings
    static let defaultColor  = "DefaultColor"  // color in color assets catalog
    static let emptyString   = ""
    
    ///User Interface
    static let imageBeaconBall = "BeaconBall"  // image in image assets catalog
    
    ///Alert Settings
    // Used for app's popup alerts
    static let alert          = "Alert"            // title of Alert
    static let titleTextColor = "titleTextColor"  // Must correspond to valid alert key
    static let ok             = "OK"               // label on button of alert
    
    ///Alert Messages
    static let labelNoBluetooth   = "No Bluetooth"
    static let noBluetooth        = "This device does not have bluetooth powered on."
    static let noBluetoothSupport = "The device running this app does not support bluetooth."
    static let simulator          = "Unfortunately simulators lack bluetooth capabilities needed to act as a bluetooth beacon. Please use this app on an iOS device with bluetooth."
    
    /// Pulse Settings
    static let transmitting                    = "Transmitting" // label on button when beacon is transmitting
    static let start                           = "START"        // label on button when beacon is off
    static let pulseAnimationKey               = "pulse"        //
    static let opacity                         = "opacity"        // valid key for CAKeyframeAnimation
    static let scaleXY                         = "transform.scale.xy"  // valid key for CABasicAnimation
    static let numPulse                        = 9
    static let radius: CGFloat                 = 300
    static let repeatMax                       = MAXFLOAT
    static let instanceDelay                   = 1.0
    static let animationDuration: TimeInterval = 8
    static let alpha : CGFloat                 = 0.75
    static let scaleAnimationFrom              = 0.25
    static let scaleAnimationTo                = 1.0
    static let keyValues: [NSNumber]           = [0.0, 0.3, 1.0]
}


