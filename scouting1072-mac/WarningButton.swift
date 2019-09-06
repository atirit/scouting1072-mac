//
//  WarningButton.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 3/6/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa

var warningButton: NSButton!

class WarningButton: NSButton {
    override func awakeFromNib() {
        self.target = self
        self.action = #selector(warn)
        warningButton = self
    }
    
    @objc func warn() {
        warningWindow = mainStoryboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("warningWindowController")) as? NSWindowController
        warningWindow?.showWindow(nil)
        self.isEnabled = false
    }
}
