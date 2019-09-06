//
//  RescanCheckbox.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 3/22/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa

var isRescanning = false

class RescanCheckbox: NSButton {
    override func awakeFromNib() {
        self.target = self
        self.action = #selector(rescanChanged)
    }
    
    @objc func rescanChanged() {
//        switch self.state {
//        case .on:
//            self.state = .off
//        case .off:
//            self.state = .on
//        default: break
//        }
        isRescanning = self.state == .on
        print(isRescanning)
    }
}
