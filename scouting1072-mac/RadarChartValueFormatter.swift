//
//  RadarChartValueFormatter.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 2/28/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa
import Charts

class RadarChartValueFormatter: IAxisValueFormatter {
    let radarChartTitles = ["Low Cargo", "Mid Cargo", "High Cargo", "Low Hatch", "Mid Hatch", "High Hatch"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if radarChartTitles.count > Int(value) {
            return radarChartTitles[Int(value)]
        } else {
            return ""
        }
    }
}
