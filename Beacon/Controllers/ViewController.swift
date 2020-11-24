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

    
    var beaconRegion : CLBeaconRegion?
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
        stopAdvertising()
        advertise()
    }
    
    func setupPulse(view: UIView) {
        pulseGraphic.position = CGPoint(x: view.frame.size.width / 2 , y: view.frame.size.height / 2)

        print("Position:", pulseGraphic.position)
        pulseGraphic.numPulse          = K.numPulse
        pulseGraphic.radius            = K.radius
        pulseGraphic.animationDuration = K.animationDuration
        pulseGraphic.backgroundColor   = K.backgroundColor
        
        view.layer.addSublayer(pulseGraphic)
    }
    
    
    @IBAction func startBeacon(_ sender: Any) {

   //     print("title", String(beaconSignalButton.title(for: .normal) ?? "Unknown Title"))
        
        if beaconSignalButton.title(for: .normal) == "Transmitting" {
            stopAdvertising()
//            beaconSignalButton.setTitle("Start Beacon", for: .normal)
//            peripheralManager.stopAdvertising()
        } else {
            advertise()
//            pulseGraphic.start()
//            beaconSignalButton.setTitle("Advertising", for: .normal)
        }
    }
    
    func stopAdvertising() {
        labelBeacon.text = ""
        pulseGraphic.stop()
        peripheralManager.stopAdvertising()
    }
    
    func advertise() {
        if peripheralManager.state == .poweredOn {
            if let beaconRegion = beaconRegion {
                print("advertising")
                advertiseDevice(region: beaconRegion)
                pulseGraphic.start()
                labelBeacon.text = "Transmitting"
            }
        }
    }
    
    
    func createBeaconRegion(major: CLBeaconMajorValue, minor: CLBeaconMinorValue) -> CLBeaconRegion? {
        
        guard let proximityUUID = UUID(uuidString: K.uuid) else { return nil }
        
        let beaconID                  = K.beaconID
        uuid.text                     = K.uuid
        labelBeaconID.text            = K.beaconID
        
        return CLBeaconRegion(proximityUUID: proximityUUID,
                              major        : major,
                              minor        : minor,
                              identifier   : beaconID)
    }
    
    
    func advertiseDevice(region : CLBeaconRegion) {
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        peripheralManager.startAdvertising(((peripheralData as NSDictionary) as? [String : Any]))
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
                print("unsupported")
            case .unauthorized:
                print("unauthorized")
            case .poweredOff:
                print("poweredOff")
                peripheralManager.stopAdvertising()
            case .poweredOn:
                print("poweredOn")
                //advertise()
            default:
                print("❌ Check for additional cases of state on CBCentralManager ")
        }
    }
}

