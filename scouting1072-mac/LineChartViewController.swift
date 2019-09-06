//
//  LineChartViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 2/24/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa
import Charts

let colors : [NSUIColor] = [.systemGreen, .systemRed, .systemBlue, .systemYellow, .systemPurple, .systemOrange]

class LineChartViewController: NSViewController {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var pieceType: NSSegmentedControl!
    @IBAction func selectionChanged(_ sender: Any) {
        setUpChart()
    }
    
    @IBOutlet weak var teamsField: NSTextField!
    @IBAction func textChanged(_ sender: Any) {
        teamsField.window?.makeFirstResponder(self)
        var tempTeams : [Int] = []
        for teamString in teamsField.stringValue.components(separatedBy: ",") {
            if let team = Int(teamString.trimmingCharacters(in: .whitespaces)) {
                if teams.contains(team) {
                    tempTeams.append(team)
                }
            }
        }
        lineChartTeams = tempTeams
        setUpChart()
    }
    
    var lineChartTeams : [Int] = []
    let hatches = true
    
    func setUpChart() {
        let chartData = LineChartData()
        for (i, team) in lineChartTeams.enumerated() {
            guard let teamData = fullData[team] else { return }
            var matches : [Int : Bool] = [:]
            for d in teamData {
                matches[d.matchNumber] = true
            }
            let matchOrdered = teamData.sorted { $0.matchNumber < $1.matchNumber }.filter { let b = matches[$0.matchNumber]!; matches[$0.matchNumber] = false; return b }
            let dataSet : [ChartDataEntry] = matchOrdered.enumerated().map { arg in
                let (x, y) = arg
                var total = 0
                switch pieceType.selectedSegment {
                case 0: total = y.lowCargo + y.midCargo + y.highCargo
                case 1: total = y.lowHatches + y.midHatches + y.highHatches
                case 2: total = y.lowCargo + y.midCargo + y.highCargo + y.lowHatches + y.midHatches + y.highHatches
                default: break
                }
                return ChartDataEntry(x: Double(x), y: Double(total))
            }
            let newDataSet = LineChartDataSet(values: dataSet, label: "\(team)")
            if i <= colors.count - 1 {
                newDataSet.colors = [colors[i]]
                newDataSet.circleColors = [colors[i]]
                newDataSet.drawCircleHoleEnabled = false
                newDataSet.circleRadius = 5.0
                newDataSet.lineDashLengths = [5, 5]
                newDataSet.drawValuesEnabled = false
                newDataSet.setDrawHighlightIndicators(false)
                chartData.addDataSet(newDataSet)
            }
        }
        
        if chartData.dataSets.count > 0 {
            chartView.data = chartData
        } else {
            chartView.data = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.legend.textColor = .labelColor
        chartView.xAxis.labelTextColor = .labelColor
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.granularity = 1
        chartView.xAxis.granularityEnabled = true
        chartView.leftAxis.labelTextColor = .labelColor
        chartView.leftAxis.granularity = 1
        chartView.leftAxis.granularityEnabled = true
        chartView.leftAxis.xOffset = 10
        chartView.rightAxis.enabled = false
        chartView.scaleYEnabled = false
        chartView.scaleXEnabled = false
        chartView.noDataTextColor = .labelColor
    }
    
    override func viewWillAppear() {
        //chartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.0)
    }
}
