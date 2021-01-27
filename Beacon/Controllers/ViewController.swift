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
    let alertManager      = AlertManager()

    @IBOutlet var labelBeacon        : UILabel!
    @IBOutlet var beaconSignalButton : UIButton!
    @IBOutlet var uuid               : UILabel!
    @IBOutlet var segmentMajor       : UISegmentedControl!
    @IBOutlet var segmentMinor       : UISegmentedControl!
    @IBOutlet var labelBeaconID      : UILabel!

    var beaconRegion : CLBeaconRegion!
    var timer        : Timer!
    var scale        : CGFloat = 1.0
    var didNotify    : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBeacon()
        setupPulse(view: beaconSignalButton)
     //   setupSVG()
        peripheralManager.delegate = self
    }
    
    //MARK: - IBActions
    /// Switch segment control
    @IBAction func pickedSelectors(_ sender: UISegmentedControl) {
        beaconRegion = createBeaconRegion(uuid       : K.uuid,
                                          major      : CLBeaconMajorValue(segmentMajor.selectedSegmentIndex + 1),
                                          minor      : CLBeaconMinorValue(segmentMinor.selectedSegmentIndex + 1),
                                          identifier : K.beaconID)
        startAdvertising()
    }
    
    
    /// Switch beacon on and off
    @IBAction func touchBeacon(_ sender: Any) {
        labelBeacon.text == K.transmitting ? stopAdvertising() : startAdvertising()
    }
    
    
    /// Initialize beacon
    func setupBeacon() {
        
        segmentMajor.selectedSegmentIndex = 0
        segmentMinor.selectedSegmentIndex = 0
        
        beaconRegion = createBeaconRegion(uuid: K.uuid, major: K.major, minor: K.minor, identifier: K.beaconID )
  
    }
    
    
    /// Set up pulse based on provided settings
    func setupPulse(view: UIView) {
        
        pulseGraphic.position = CGPoint(x: view.frame.size.width / 2 , y: view.frame.size.height / 2)
        pulseGraphic.numPulse          = K.numPulse
        pulseGraphic.radius            = K.radius
        pulseGraphic.animationDuration = K.animationDuration
        pulseGraphic.backgroundColor   = UIColor(named: K.defaultColor)?.cgColor
        
        view.layer.addSublayer(pulseGraphic)
    }
    
    
    /// Start Advertising
    func startAdvertising() {
        
        guard let beaconRegion = beaconRegion else { return }
        
        labelBeacon.text = K.transmitting
        
        if peripheralManager.state == .poweredOn {
            advertiseDevice(region: beaconRegion)
        } else {
            #if targetEnvironment(simulator)
            didNotify == false ? alertManager.showAlert(self, message: K.simulator) : print(K.simulator)
            didNotify = true
            #else
            alertManager.showAlert(self, message: K.noBluetooth)
            print(K.noBluetooth)
            #endif
        }
    }
    
    
    /// Stop advertising
    func stopAdvertising() {
        
        labelBeacon.text = K.nothing
        
        if pulseGraphic.pulse.isAnimating() == true {
            pulseGraphic.stop()
        }

        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }
    }
    
    
    
/// Advertise device using peripheral manager
    func advertiseDevice(region : CLBeaconRegion) {
        
        if pulseGraphic.pulse.isAnimating() == false {
            pulseGraphic.start()
        }
        
        let peripheralData = region.peripheralData(withMeasuredPower: nil) as? [String : Any]
        
        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }
        
        peripheralManager.startAdvertising(peripheralData)
    }
    
    
/// Create beacon region based on provided details
    func createBeaconRegion(uuid: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String) -> CLBeaconRegion? {
        
        guard let proximityUUID = UUID(uuidString: K.uuid) else { return nil }
        
        self.uuid.text     = uuid
        let beaconID       = K.beaconID
        labelBeaconID.text = K.beaconID
        
        return CLBeaconRegion(proximityUUID: proximityUUID,
                              major        : major,
                              minor        : minor,
                              identifier   : beaconID)
    }

} // end of ViewController


/// 
extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
            case .unknown:
                print("unknown")
            case .resetting:
                print("resetting")
            case .unsupported:
                alertManager.showAlert(self, message: K.noBluetoothSupport )
                print(K.noBluetoothSupport)
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

