//
//  ReadyButton.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 2/3/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa

var readyButton: NSButton!

class ReadyButton: NSButton {
    override func awakeFromNib() {
        self.target = self
        self.action = #selector(ready)
        readyButton = self
    }
    
    @objc func ready() {
        self.isEnabled = false
        print(teams.count)
    }
}
