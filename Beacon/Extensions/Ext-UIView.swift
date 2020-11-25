//
//  Ext-UIView.swift
//  Beacon
//
//  Created by Marcy Vernon on 11/24/20.
//  Copyright © 2020 Marcy Vernon. All rights reserved.
//

import UIKit

extension CALayer {

        func isAnimating() -> Bool {
            return (self.animationKeys()?.count ?? 0) > 0
        }
}
