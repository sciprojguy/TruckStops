//
//  UserLocationMapPin.swift
//  TruckStops
//
//  Created by Chris Woodard on 5/8/18.
//  Copyright © 2018 Code. All rights reserved.
//

import UIKit
import MapKit

@objc class UserLocationMapPin: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            if let img = UIImage(named: "truck") {
                self.image = img
            }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
