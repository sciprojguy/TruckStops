//
//  TruckStopAnnotation.swift
//  TruckStops
//
//  Created by Chris Woodard on 5/3/18.
//  Copyright © 2018 Code. All rights reserved.
//

import UIKit
import MapKit

class TruckStopMapPin: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            if let img = UIImage(named: "location.png") {
                self.image = img
            }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            if let img = UIImage(named: "location-selected.png") {
                self.image = img
            }
        }
        else {
            if let img = UIImage(named: "location.png") {
                self.image = img
            }
        }
    }
}
