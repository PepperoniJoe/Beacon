//
//  ViewController.swift
//  Beacon
//
//  Created by Marcy Vernon on 11/13/20.
//  Copyright © 2020 Marcy Vernon. All rights reserved.
//


import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController {
    
    let peripheralManager = CBPeripheralManager()
    let pulseGraphic      = PulseGraphic()

    @IBOutlet var labelBeacon        : UILabel!
    @IBOutlet var beaconSignalButton : UIButton!
    @IBOutlet var uuid               : UILabel!
    @IBOutlet var segmentMajor       : UISegmentedControl!
    @IBOutlet var segmentMinor       : UISegmentedControl!
    @IBOutlet var labelBeaconID      : UILabel!

    var beaconRegion : CLBeaconRegion!
    var timer        : Timer!
    var scale        : CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        peripheralManager.delegate = self
    }
    
    func setup() {
        segmentMajor.selectedSegmentIndex = 0
        segmentMinor.selectedSegmentIndex = 0
        beaconRegion = createBeaconRegion(major: K.major, minor: K.minor)
        setupPulse(view: beaconSignalButton)
    }
    
    @IBAction func pickedSelectors(_ sender: UISegmentedControl) {
        beaconRegion = createBeaconRegion(major: CLBeaconMajorValue(segmentMajor.selectedSegmentIndex + 1),
                                          minor: CLBeaconMinorValue(segmentMinor.selectedSegmentIndex + 1))
        startAdvertising()
    }
    
    
    @IBAction func touchBeacon(_ sender: Any) {
        
//        if beaconSignalButton.title(for: .normal) == K.transmitting {
        if labelBeacon.text == K.transmitting {
            stopAdvertising()
        } else {
            startAdvertising()
        }
    }
    
    
    func setupPulse(view: UIView) {
        
        pulseGraphic.position = CGPoint(x: view.frame.size.width / 2 , y: view.frame.size.height / 2)
        pulseGraphic.numPulse          = K.numPulse
        pulseGraphic.radius            = K.radius
        pulseGraphic.animationDuration = K.animationDuration
        pulseGraphic.backgroundColor   = K.backgroundColor
        
        view.layer.addSublayer(pulseGraphic)
    }
    
    
    func stopAdvertising() {
        
        labelBeacon.text = K.nothing
        
        if pulseGraphic.pulse.isAnimating() == true {
            pulseGraphic.stop()
        }

        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }
    }
    
    
    func startAdvertising() {
        
        guard let beaconRegion = beaconRegion else { return }
        
        labelBeacon.text = K.transmitting
        
        if peripheralManager.state == .poweredOn {
            advertiseDevice(region: beaconRegion)
        } else {
            print("Device does not have bluetooth powered on. Note: Simulators do not support bluetooth functionality. This app should be run on a real device.")
        }
    }
    
    
    func advertiseDevice(region : CLBeaconRegion) {
        
        if pulseGraphic.pulse.isAnimating() == false {
            pulseGraphic.start()
        }
        
        let peripheralData = region.peripheralData(withMeasuredPower: nil) as? [String : Any]
        
        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }
        
        peripheralManager.startAdvertising(peripheralData)
        print("advertising")
    }
    
    
    func createBeaconRegion(major: CLBeaconMajorValue, minor: CLBeaconMinorValue) -> CLBeaconRegion? {
        
        guard let proximityUUID = UUID(uuidString: K.uuid) else { return nil }
        
        let beaconID       = K.beaconID
        uuid.text          = K.uuid
        labelBeaconID.text = K.beaconID
        
        return CLBeaconRegion(proximityUUID: proximityUUID,
                              major        : major,
                              minor        : minor,
                              identifier   : beaconID)
    }

    
} // end of ViewController


extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
            case .unknown:
                print("unknown")
            case .resetting:
                print("resetting")
            case .unsupported:
                print("The device running this app does not support bluetooth.")
            case .unauthorized:
                print("unauthorized")
            case .poweredOff:
                print("Bluetooth powered Off")
                peripheralManager.stopAdvertising()
            case .poweredOn:
                print("Bluetooth powered on")
            default:
                print("❌ Check for additional cases of state on CBCentralManager ")
        }
    }
}

