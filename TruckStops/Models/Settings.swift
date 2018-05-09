//
//  Settings.swift
//  TruckStops
//
//  Created by Chris Woodard on 5/9/18.
//  Copyright © 2018 Code. All rights reserved.
//

import UIKit

@objc public class Settings: NSObject {

    var mapType:Int = 0
    var cachePath:String = ""
    
    static var shared:Settings = Settings()
    private override init() {
        super.init()
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        self.cachePath = "\(paths[0])/Settings.plist"
        self.load()
    }
    
    func setMapType(type:Int) {
        mapType = type
        save()
    }
    
    func load() {
        if let dict = NSDictionary(contentsOfFile: self.cachePath) {
            if let type = dict["MapType"] as? Int {
                self.mapType = type
            }
        }
    }
    
    func save() {
        let dict = NSDictionary(dictionary: [
            "MapType" : self.mapType
        ])
        dict.write(toFile: self.cachePath, atomically: false)
    }
}
