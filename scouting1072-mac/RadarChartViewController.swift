//
//  RadarChartViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 2/28/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa
import Charts

class RadarChartViewController: NSViewController {
    @IBOutlet weak var radarChart: RadarChartView!
    
    @IBOutlet weak var teamsField: NSTextField!
    @IBAction func textChanged(_ sender: Any) {
        teamsField.window?.makeFirstResponder(self)
        var tempTeams : [Int] = []
        for teamString in teamsField.stringValue.components(separatedBy: ",") {
            if let team = Int(teamString.trimmingCharacters(in: .whitespaces)) {
                if teams.contains(team) {
                    tempTeams.append(team)
                }
            } else {
                if let i = fabricatedNames.firstIndex(of: teamString) {
                    tempTeams.append(-i)
                }
            }
        }
        radarChartTeams = tempTeams
        setUpChart()
    }
    
    var radarChartTeams : [Int] = []
    
    func setUpChart() {
        let chartData = RadarChartData()
        for (i, team) in radarChartTeams.enumerated() {
            var dataSet : [RadarChartDataEntry] = []
            if team > 0 {
                guard let teamAverages = averages[team] else { return }
                dataSet.append(RadarChartDataEntry(value: Double(teamAverages[0].value)))
                dataSet.append(RadarChartDataEntry(value: Double(teamAverages[1].value)))
                dataSet.append(RadarChartDataEntry(value: Double(teamAverages[2].value)))
                dataSet.append(RadarChartDataEntry(value: Double(teamAverages[3].value)))
                dataSet.append(RadarChartDataEntry(value: Double(teamAverages[4].value)))
                dataSet.append(RadarChartDataEntry(value: Double(teamAverages[5].value)))
            } else {
                var data : ScoutingData!
                if fabricatedData.indices.contains(-team) {
                    data = fabricatedData[-team]
                } else {
                    return
                }
                
                dataSet.append(RadarChartDataEntry(value: Double(data.lowCargo)))
                dataSet.append(RadarChartDataEntry(value: Double(data.midCargo)))
                dataSet.append(RadarChartDataEntry(value: Double(data.highCargo)))
                dataSet.append(RadarChartDataEntry(value: Double(data.lowHatches)))
                dataSet.append(RadarChartDataEntry(value: Double(data.midHatches)))
                dataSet.append(RadarChartDataEntry(value: Double(data.highHatches)))
            }
            
            let newDataSet = RadarChartDataSet(values: dataSet, label: "\(team > 0 ? String(team) : fabricatedNames[-team])")
            if i <= colors.count - 1 {
                newDataSet.colors = [colors[i]]
                newDataSet.fillColor = colors[i]
                newDataSet.drawValuesEnabled = false
                newDataSet.setDrawHighlightIndicators(false)
                newDataSet.drawFilledEnabled = true
                newDataSet.lineWidth = 5
                chartData.addDataSet(newDataSet)
            }
        }
        
        if chartData.dataSets.count > 0 {
            radarChart.data = chartData
        } else {
            radarChart.data = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radarChart.yAxis.axisMinimum = 0.0
        radarChart.xAxis.valueFormatter = RadarChartValueFormatter()
        radarChart.yAxis.granularity = 1
        radarChart.yAxis.drawLabelsEnabled = false
        radarChart.legend.textColor = .labelColor
        radarChart.xAxis.labelTextColor = .labelColor
        radarChart.noDataTextColor = .labelColor
        // Do view setup here.
    }
    
}
