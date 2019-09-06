//
//  ScanButton.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 1/18/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa

var scanButton: NSButton!

class ScanButton: NSButton {
    override func awakeFromNib() {
        self.target = self
        self.action = #selector(scan)
        scanButton = self
    }
    
    @objc func scan() {
        scanWindow = mainStoryboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("scanWindowController")) as? NSWindowController
        scanWindow?.showWindow(nil)
        scanButton.isEnabled = false
    }
}
