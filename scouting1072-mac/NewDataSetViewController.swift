//
//  NewDataSetViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 3/4/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa

var fabricatedNames : [String] = []
var fabricatedData : [ScoutingData] = []

class NewDataSetViewController: NSViewController {
    @IBOutlet weak var lowCargoField: NSTextField!
    @IBOutlet weak var midCargoField: NSTextField!
    @IBOutlet weak var highCargoField: NSTextField!
    
    @IBOutlet weak var lowHatchField: NSTextField!
    @IBOutlet weak var midHatchField: NSTextField!
    @IBOutlet weak var highHatchField: NSTextField!
    
    @IBOutlet weak var nameField: NSTextField!
    
    @IBAction func save(_ sender: Any) {
        if !nameField.stringValue.isEmpty {
            fabricatedNames.append(nameField.stringValue.trimmingCharacters(in: .whitespaces))
            fabricatedData.append(ScoutingData(teamNumber: 0, matchNumber: 0, scouter: "fabricated", teamColor: .red, startPosition: .middleBottom, preload: .hatchPanel, shipPreload: [.hatchPanel, .hatchPanel, .hatchPanel, .hatchPanel, .hatchPanel, .hatchPanel], lowCargo: Int(lowCargoField.stringValue) ?? 0, lowHatches: Int(lowHatchField.stringValue) ?? 0, midCargo: Int(midCargoField.stringValue) ?? 0, midHatches: Int(midHatchField.stringValue) ?? 0, highCargo: Int(highCargoField.stringValue) ?? 0, highHatches: Int(highHatchField.stringValue) ?? 0, defending: 0, droppedPieces: 0, fouls: 0, bricked: false, climbLevel: 0, wasAssisted: false, assistedClimb: false, defenseLevel: 0, comments: "", fabricated: true))
            self.view.window?.close()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
