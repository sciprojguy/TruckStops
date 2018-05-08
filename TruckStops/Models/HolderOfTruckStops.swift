//
//  HolderOfTruckStops.swift
//  TruckStops
//
//  Created by Chris Woodard on 5/3/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import UIKit
import MapKit

@objc class TruckStop : NSObject, MKAnnotation {
    var title:String?       //name
    var subtitle:String?
    var coordinate: CLLocationCoordinate2D
    var rawline1:String?
    var rawline2:String?
    var rawline3:String?
    var city:String?
    var state:String?
    var country:String?
    var zip:String?
    override init() {
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.title = nil
        self.subtitle = nil
        self.rawline1 = nil
        self.rawline2 = nil
        self.rawline3 = nil
        self.city = nil
        self.state = nil
        self.country = nil
        self.zip = nil
        super.init()
    }
    
    convenience init(truckStopDict:[String:Any]) {
    
        self.init()
        
        self.title = truckStopDict["name"] as? String ?? ""
        
        var subtitle = ""
        
        if let city = truckStopDict["city"] as? String {
            subtitle += city + " "
        }
        
        if let state = truckStopDict["state"] as? String {
            subtitle += state + " "
        }
        
        if let country = truckStopDict["country"] as? String {
            subtitle += country
        }
       
        self.subtitle = subtitle
        
        if let lat = truckStopDict["lat"] as? String,
           let lon = truckStopDict["lng"] as? String {
            let laat = Double(lat)
            let loon = Double(lon)
            self.coordinate.latitude = laat!
            self.coordinate.longitude = loon!
        }
        
        self.rawline1 = truckStopDict["rawLine1"] as? String ?? ""
        self.rawline2 = truckStopDict["rawLine2"] as? String ?? ""
        self.rawline3 = truckStopDict["rawLine3"] as? String ?? ""
        self.city = truckStopDict["city"] as? String ?? ""
        self.state = truckStopDict["state"] as? String ?? ""
        self.country = truckStopDict["country"] as? String ?? ""
        self.zip = truckStopDict["zip"] as? String ?? ""
    }
    
    override var description: String {
        get {
            return "title = \(self.title ?? ""), lat = \(self.coordinate.latitude), lon = \(self.coordinate.longitude), rawlines: 1 = \(self.rawline1 ?? ""), 2 =\(self.rawline2 ?? ""), 3 = \(self.rawline3 ?? "")"
        }
    }
}

@objc public class HolderOfTruckStops: NSObject {

    var truckStopArray:[[String:Any]] = []
    
    convenience init(truckStopsFromResults:[[String:Any]]) {
        self.init()
        self.truckStopArray = truckStopsFromResults
    }
    
    @objc func numberOfPins() -> Int {
        return self.truckStopArray.count
    }
    
    @objc func pins(containing filteredBy:String?=nil) -> [TruckStop] {
        var pinsArray:[TruckStop] = []
        var searchWords:[String] = []
        var wordFound:[String:Bool] = [:]
        
        if let filterStr = filteredBy {
            let trimmed = filterStr.trimmingCharacters(in: CharacterSet.whitespaces)
            if 0 < trimmed.count {
                searchWords = trimmed.components(separatedBy: " ").map { return $0.lowercased()}
            }
        }
        
        for truckStopInfo in self.truckStopArray {
        
            var includeTruckstop = true
            let stopName = truckStopInfo["name"] as? String ?? ""
            let stopCity = truckStopInfo["city"] as? String ?? ""
            let stopState = truckStopInfo["state"] as? String ?? ""
            let stopCountry = truckStopInfo["country"] as? String ?? ""
            let stopZip = truckStopInfo["zip"] as? String ?? ""
            let rawLine1 = truckStopInfo["rawLine1"] as? String ?? ""
            let rawLine2 = truckStopInfo["rawLine2"] as? String ?? ""
            let rawLine3 = truckStopInfo["rawLine3"] as? String ?? ""

            if searchWords.count > 0 {
                
                //search name, city, country, state, and zip
                for word in searchWords {
                    
                    wordFound[word] = false
                    
                    if stopName.lowercased().contains(word) {
                        wordFound[word] = true
                    }
                    if stopCity.lowercased().contains(word) {
                        wordFound[word] = true
                    }
                    if stopState.lowercased().contains(word) {
                        wordFound[word] = true
                    }
                    if stopCountry.lowercased().contains(word) {
                        wordFound[word] = true
                    }
                    if stopZip.lowercased().contains(word) {
                        wordFound[word] = true
                    }
                    if rawLine1.lowercased().contains(word) {
                        wordFound[word] = true
                    }
                    if rawLine2.lowercased().contains(word) {
                        wordFound[word] = true
                    }
                    if rawLine3.lowercased().contains(word) {
                        wordFound[word] = true
                    }
                }
                
                includeTruckstop = true
                for word in searchWords {
                    includeTruckstop = includeTruckstop && wordFound[word]!
                }
            }

            if includeTruckstop {
                let truckStop = TruckStop(truckStopDict: truckStopInfo)
                pinsArray.append(truckStop)
            }
        }
        return pinsArray
    }
}
