//
//  ViewController.swift
//  Beacon
//
//  Created by Marcy Vernon on 11/13/20.
//  Copyright © 2020 Marcy Vernon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Objects
    let beaconManager = BeaconManager()  // manages beacon activity
    let pulseGraphic  = PulseGraphic()  // pulsating graphic
    let alertManager  = AlertManager()   // alerts

    //MARK: - IBOutlets
    @IBOutlet var labelBeacon        : UILabel!  // Title
    @IBOutlet var beaconSignalButton : UIButton! // start/transmit button
    @IBOutlet var uuid               : UILabel!
    @IBOutlet var segmentMajor       : UISegmentedControl!
    @IBOutlet var segmentMinor       : UISegmentedControl!
    @IBOutlet var labelBeaconID      : UILabel!
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBeaconDetails()
        setupPulse(view: beaconSignalButton)
        beaconManager.delegate = self
    }
    
    /// Set up beacon
    func setupBeaconDetails() {
        beaconManager.createBeaconRegion()
        uuid.text          = K.uuid
        labelBeaconID.text = K.beaconID
    }
    
    /// Set up pulse based on provided settings
    func setupPulse(view: UIView) {
        pulseGraphic.position = CGPoint(x: view.frame.size.width / 2 , y: view.frame.size.height / 2)
        view.layer.addSublayer(pulseGraphic)
    }
    
    //MARK: - IBActions
    /// Switch segment control
    @IBAction func pickedSelectors(_ sender: UISegmentedControl) {
        beaconManager.createBeaconRegion(majorIndex: segmentMajor.selectedSegmentIndex,
                                         minorIndex: segmentMinor.selectedSegmentIndex)
        beaconManager.startAdvertising()
    }
    
    /// Switch beacon on and off
    @IBAction func touchBeacon(_ sender: Any) {
        guard beaconManager.isBluetoothAvailable == true else {
            labelBeacon.text = K.labelNoBluetooth
            return
        }
        
        labelBeacon.text == K.transmitting ? beaconManager.stopAdvertising() : beaconManager.startAdvertising()
    }
} // end of ViewController


extension ViewController: BeaconManagerDelegate {
    
    func showAlert(message: String) {
        alertManager.showAlert(self, message: message)
    }
    
    func advertiseDevice() {
        if pulseGraphic.pulse.isAnimating() == false { pulseGraphic.start() }
    }
    
    func stopAdvertising() {
        labelBeacon.text = K.start
        if pulseGraphic.pulse.isAnimating() == true { pulseGraphic.stop() }
    }
    
    func startAdvertising() {
        labelBeacon.text = K.transmitting
    }

}
