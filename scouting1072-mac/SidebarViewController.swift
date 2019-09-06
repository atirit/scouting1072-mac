//
//  SidebarViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 1/21/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa
import Quartz

var sidebarGlobal : NSTableView!

var currentRow = 0

var currentTeam = 0 {
    didSet {
        infoViewController.updateAverages(withTeam: currentTeam)
        commentsTableGlobal.reloadData()
    }
}
var teams : [Int] = [] {
    didSet {
        sidebarGlobal.reloadData()
    }
}

var searchTeams : [Int] = [] {
    didSet {
        currentTeam = searchTeams.first ?? teams.first ?? 0
        sidebarGlobal.reloadData()
    }
}

var shouldUseSearchTeams = false

var teamNames : [Int: String] = [100: "The WildHats", 199: "Deep Blue", 585: "Cyber Penguins", 701: "RoboVikes", 751: "barn2robotics", 766: "M-A Bears", 973: "Greybots", 1056: "Hot Rocks", 1072: "Harker Robotics", 1280: "Ragin' C- Biscuits", 1323: "MadTown Robotics", 1351: "TKO", 1388: "Eagle Robotics", 1422: "The Neon Knights", 1458: "Red Tie Robotics", 1662: "Raptor Force Engineering", 1671: "Buchanan Bird Brains", 1678: "Citrus Circuits", 1967: "The Janksters", 2085: "RoboDogs", 2135: "Presentation Invasion", 2141: "Spartonics", 2204: "Rambots", 2367: "Lancer Robotics", 2473: "Goldstrikers", 2489: "The Insomniacs", 2551: "Penguin Empire", 2813: "Gear Heads", 2839: "Daedalus", 2854: "The Prototypes", 3013: "Zombots", 3189: "Circuit Breakers", 3250: "Kennedy Robotics", 3257: "Vortechs", 3303: "Metallic Thunder", 3482: "Arrowbotics", 3495: "MindCraft Robotics", 3598: "SEStematic Eliminators", 3615: "Reavers", 3669: "RoboKnights", 3859: "Wolfpack Robotics", 3880: "Tiki Techs", 3970: "Duncan Dynamics", 4135: "Iron Patriots", 4643: "Butte Built Bots", 4698: "Raider Robotics", 4904: "Bot-Provoking", 5026: "Iron Panthers", 5027: "Event Horizon", 5102: "The Underbots", 5104: "BreakerBots", 5134: "RoboWolves", 5250: "Kinetic", 5274: "Wolverines", 5419: "Natural Disasters", 5430: "Pirate Robolution", 5458: "Digital Minds", 5461: "V.E.R.N", 5480: "FYRE (FIRST Young Robotics Engineers)", 5496: "Robo Knights", 5507: "Robotic Eagles", 5728: "MC²", 5817: "Uni-Rex", 5852: "Illusion Robotics", 5871: "Chickadees", 5875: "ICE Cubed", 5940: "B.R.E.A.D.", 6174: "Kaprekar's Constants", 6238: "POPCORN PENGUINS", 6241: "CowTech", 6305: "Stable Circuits", 6358: "The Buhlean Operators", 6474: "Indigo Dynamics", 6506: "Steel Boot", 6612: "NexGen Robotics", 6619: "GravitechX", 6644: "Atomic Automatons", 6657: "Arborbotics", 6662: "FalconX", 6711: "Millenial Falcons", 6804: "Team Wolfpack", 6883: "Leviathan Robotics", 6884: "Deep-Space", 6918: "Cellar Rats", 6926: "RobotiCats", 6981: "Clockwork Soldiers", 7057: "Titanators", 7137: "Project 212", 7229: "Electronic Eagles", 7413: "Plus Ultra", 7524: "Regen", 7529: "Mulan", 7589: "Lishan Blue Magpie", 7663: "Sleuth Robotics", 7802: "Dust Devils", 7870: "The RoboHawks"]

class SidebarViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    @IBOutlet weak var sidebar: NSTableView!
    @IBOutlet weak var noDataLabel: NSTextField!
    @IBOutlet weak var searchField: NSSearchField!
    @IBAction func textChanged(_ sender: Any) {
        print(searchField.stringValue)
        if searchField.stringValue.isEmpty {
            shouldUseSearchTeams = false
            searchTeams = []
        } else {
            if let _ = Int(searchField.stringValue) {
                let keys = teams.map { return String($0) }
                shouldUseSearchTeams = true
                searchTeams = keys.filter { $0.contains(searchField.stringValue) }.map { return Int($0)! }.sorted()
            } else {
                let values = teamNames.values.map { return String($0) }
                shouldUseSearchTeams = true
                searchTeams = values.filter { $0.localizedCaseInsensitiveContains(searchField.stringValue) }.map { s in return teamNames.first { $0.1 == s }!.0 }.filter { teams.contains($0) }.sorted()
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var image: NSImage?
        var text: String = ""
        var subText: String = ""
        
        let item = (shouldUseSearchTeams ? searchTeams : teams).sorted()[row]
        if FileManager.default.fileExists(atPath: robotImageDirString + "\(item).jpeg") {
            image = NSImage(byReferencing: URL(fileURLWithPath: robotImageDirString + "\(item).jpeg"))
        } else {
            image = NSImage(byReferencing: URL(fileURLWithPath: robotImageDirString + "254old.png"))
        }
            //Bundle.main.url(forResource: "hmm", withExtension: "jpg")!)
        text = String(describing: item)
        subText = teamNames[item] ?? ""
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MyCell"), owner: nil) as? SidebarTableCellView {
            cell.teamNumberField.stringValue = text
            cell.teamNameField.stringValue = subText
            cell.robotImageView.image = image
            return cell
        }
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (shouldUseSearchTeams ? searchTeams : teams).count <= 0 {
            noDataLabel.isHidden = false
            sidebar.isHidden = true
        } else {
            noDataLabel.isHidden = true
            sidebar.isHidden = false
        }
        return (shouldUseSearchTeams ? searchTeams : teams).count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = sidebar.selectedRow
        currentRow = row
        if row > -1 {
            guard let cell = sidebar.view(atColumn: sidebar.selectedColumn, row: row, makeIfNecessary: false) else { return }
            let newCell = cell as! SidebarTableCellView
            currentTeam = Int(newCell.teamNumberField.stringValue) ?? 0
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return nil
    }
    
    var previewPanel : QLPreviewPanel? = nil
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return 1
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return RobotPreviewItem()
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49 {
            if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared()!.isVisible {
                QLPreviewPanel.shared().orderOut(nil)
            } else {
                QLPreviewPanel.shared().makeKeyAndOrderFront(nil)
            }
        }
    }
    
    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        return true
    }
    
    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        previewPanel = panel
        panel.delegate = self
        panel.dataSource = self
    }
    
    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        previewPanel = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sidebar.delegate = self
        sidebar.dataSource = self
        sidebarGlobal = sidebar
        // Do view setup here.
    }
    
}
