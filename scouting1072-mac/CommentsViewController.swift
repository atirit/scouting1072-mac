//
//  CommentsViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 3/20/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa

var commentsTableGlobal: NSTableView!

extension String {
    var width: CGFloat {
        let field = NSTextField()
        field.stringValue = self
        field.sizeToFit()
        return field.frame.width
    }
}

class CommentsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.title == "Username" {
            // usernames
            if let values = comments[currentTeam]?.values {
                let array = Array(values)
                if array.count > row {
                    let label = NSTextField(wrappingLabelWithString: array[row])
                    label.backgroundColor = .clear
                    label.isBezeled = false
                    label.isSelectable = false
                    return label
                }
            }
            return nil
        } else {
            // comments
            if let values = comments[currentTeam]?.keys {
                let array = Array(values)
                if array.count > row {
                    let label = NSTextField(wrappingLabelWithString: array[row])
                    label.backgroundColor = .clear
                    label.isBezeled = false
                    label.isSelectable = false
                    return label
                }
            }
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return comments[currentTeam]?.values.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let cell = NSTextFieldCell(textCell: Array(comments[currentTeam]!.keys)[row])
        cell.font = .systemFont(ofSize: 13.0)
        cell.wraps = true
        return cell.cellSize(forBounds: NSRect(x: tableView.tableColumns[0].width, y: 0, width: tableView.tableColumns[1].width, height: .greatestFiniteMagnitude)).height
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        tableView.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTableGlobal = tableView
        // Do view setup here.
    }
}
