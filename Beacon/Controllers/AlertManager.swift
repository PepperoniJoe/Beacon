//
//  AlertManager.swift
//  Beacon
//
//  Created by Marcy Vernon on 11/28/20.
//  Copyright © 2020 Marcy Vernon. All rights reserved.
//

import UIKit

struct AlertManager {

    func showAlert(_ viewController: UIViewController, title: String = K.alert, message: String, preferredStyle: UIAlertController.Style = .alert) {
        
        /// create the body of the alert
        let alert = UIAlertController(title  : title,
                                      message: message,
                                      preferredStyle: .alert)
        
        /// add an action (button)
        let alertAction = UIAlertAction(title: K.ok, style: .default, handler: nil)
        alertAction.setValue(UIColor(named: K.defaultColor), forKey: K.titleTextColor)
        alert.addAction(alertAction)
        
        /// show the alert
        viewController.present(alert, animated: true, completion: nil)
    }

}
