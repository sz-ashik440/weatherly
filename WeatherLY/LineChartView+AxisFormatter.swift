//
//  LineChartView+AxisFormatter.swift
//  WeatherLY
//
//  Created by Admin on 6/21/17.
//  Copyright © 2017 c4idiots. All rights reserved.
//

import UIKit
import Charts

class LineChartFormatter: NSObject, IAxisValueFormatter{
    
    var labels: [String] = []
    
    init(labels: [String]){
        super.init()
        self.labels = labels
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value)]
    }
}
