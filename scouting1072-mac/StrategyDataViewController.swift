//
//  StrategyDataViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 4/19/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa

var strategySearchData: [StrategyScoutingData] = []

class StrategyDataViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSTextField!
    @IBAction func textChanged(_ sender: Any) {
        print(searchField.stringValue)
        if searchField.stringValue.isEmpty {
            strategySearchData = Array(strategyData.values)
        } else {
            strategySearchData = []
            for (_, data) in strategyData {
                if data.comments.contains(searchField.stringValue) {
                    strategySearchData.append(data)
                }
            }
        }
        strategySearchData.sort { $0.matchNumber < $1.matchNumber }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.title == "Match Number" {
            // match numbers
            if strategySearchData.count > row {
                let label = NSTextField(wrappingLabelWithString: String(strategySearchData[row].matchNumber))
                label.backgroundColor = .clear
                label.isBezeled = false
                label.isSelectable = false
                return label
            }
            return nil
        } else {
            // comments
            if strategySearchData.count > row {
                let label = NSTextField(wrappingLabelWithString: strategySearchData[row].comments)
                label.backgroundColor = .clear
                label.isBezeled = false
                label.isSelectable = false
                return label
            }
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return strategySearchData.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 51.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
