//
//  InfoViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 1/18/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa
import ZXingObjC

var infoViewController: InfoViewController!
var mainWindow: NSWindowController!
var mainStoryboard: NSStoryboard!

class InfoViewController: NSViewController {
    @IBOutlet weak var robotImageView: NSImageView!
    
    @IBOutlet weak var lowCargoLabel: NSTextField!
    @IBOutlet weak var midCargoLabel: NSTextField!
    @IBOutlet weak var highCargoLabel: NSTextField!
    
    @IBOutlet weak var lowHatchabel: NSTextField!
    @IBOutlet weak var midHatchLabel: NSTextField!
    @IBOutlet weak var highHatchLabel: NSTextField!
    
    @IBOutlet weak var climbLevelLabel: NSTextField!
    @IBOutlet weak var assistedLabel: NSTextField!
    @IBOutlet weak var assistedOtherLabel: NSTextField!
    
    @IBOutlet weak var preloadLabel: NSTextField!
    @IBOutlet weak var startingLevelLabel: NSTextField!
    
    @IBOutlet weak var defenseStarsLabel: NSTextField!
    @IBOutlet weak var defenseTimeLabel: NSTextField!
    
    func truncateDouble(_ value: Double, to precision: Int) -> Double {
        let components = String(value).components(separatedBy: ".")
        var newValueString = components[0] + "." + components[1].dropLast(components[1].count - precision)
        if newValueString.last == "." { newValueString.append("0") }
        let newValue = Double(newValueString) ?? 0.0
        return newValue
    }
    
    public func updateAverages(withTeam team: Int) {
        if let averageData = averages[team] {
            lowCargoLabel.stringValue = "Low Cargo: \(truncateDouble(averageData[0].value, to: 1))"
            midCargoLabel.stringValue = "Mid Cargo: \(truncateDouble(averageData[1].value, to: 1))"
            highCargoLabel.stringValue = "High Cargo: \(truncateDouble(averageData[2].value, to: 1))"
            
            lowHatchabel.stringValue = "Low Hatches: \(truncateDouble(averageData[3].value, to: 1))"
            midHatchLabel.stringValue = "Mid Hatches: \(truncateDouble(averageData[4].value, to: 1))"
            highHatchLabel.stringValue = "High Hatches: \(truncateDouble(averageData[5].value, to: 1))"
            
            climbLevelLabel.stringValue = "Climb Level: \(mostOftenClimb[team]!)"
            assistedLabel.stringValue = "Assisted: \(truncateDouble(averageData[7].value, to: 1))"
            assistedOtherLabel.stringValue = "Assisted Other: \(truncateDouble(averageData[8].value, to: 1))"
            
            preloadLabel.stringValue = "Preload: \(averageData[9].value == 1 ? GamePiece.cargo.description : GamePiece.hatchPanel.description.components(separatedBy: " ").first ?? "")"
            startingLevelLabel.stringValue = "Starting Level: \(mostOftenStart[team]! + 1)"
            
            defenseStarsLabel.stringValue = "Stars: \(truncateDouble(averageData[12].value, to: 1))"
            defenseTimeLabel.stringValue = "Time: \(truncateDouble(averageData[11].value, to: 1)) s"
            
            if FileManager.default.fileExists(atPath: robotImageDirString + "\(team).jpeg") {
                robotImageView.image = NSImage(byReferencing: URL(fileURLWithPath: robotImageDirString + "\(team).jpeg"))
            } else {
                robotImageView.image = NSImage(byReferencing: URL(fileURLWithPath: robotImageDirString + "254old.png"))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainWindow = self.view.window?.windowController
        mainStoryboard = self.storyboard
        infoViewController = self
    }
    
    override func viewWillAppear() {
        updateAverages(withTeam: currentTeam)
    }
}
