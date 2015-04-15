//
//  Location.swift
//  IAGuide
//
//  Created by Omar Alejel on 1/6/15.
//  Copyright (c) 2015 Omar Alejel. All rights reserved.
//

import Foundation
import MapKit

@objc public class Location: NSObject, MKAnnotation {
    @objc public let roomNumber: Int //need to put @objc for all objects that are meant to be exposed to it
    public let title: String!
    public let coordinate: CLLocationCoordinate2D
    
    init(roomNumber number: Int, coordinate coord: CLLocationCoordinate2D) {
        self.roomNumber = number
        self.coordinate = coord
        
        if number == 999 {
            self.title = "ISC";
        } else {
            self.title = "Room \(number)"
        }
        
        super.init()
    }
}