//
//  Weather.swift
//  WeatherLY
//
//  Created by Admin on 5/12/17.
//  Copyright © 2017 c4idiots. All rights reserved.
//

import Foundation

class Daily{
    var day: String?
    var maxTemp: Int?
    var minTemp: Int?
    var icon: String?
    var summary: String?
}

class Hourly{
    var time: Int?
    var temp: Double?
    var apperentTemp: Double?
}

class Current{
    var temp: Double?
    var summary: String?
    var icon: String?
    var humidity: Int?
}
