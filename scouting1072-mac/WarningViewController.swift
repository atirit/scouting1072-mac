//
//  WarningViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 3/6/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa

var warningWindow: NSWindowController!

class WarningViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    
    override func viewDidAppear() {
        textView.string = discrepantRounds.description.dropFirst().dropLast().components(separatedBy: "], ").joined(separator: "]\n")
    }
    
    override func viewWillDisappear() {
        warningButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
