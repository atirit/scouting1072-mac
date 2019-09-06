//
//  AppDelegate.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 1/18/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Foundation

let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
var csvURL = URL(fileURLWithPath: "/")
var assistantURL = URL(fileURLWithPath: "/")
var strategyURL = URL(fileURLWithPath: "/")
var defenseURL = URL(fileURLWithPath: "/")
var foulsURL = URL(fileURLWithPath: "/")
var dataURLString = "~/Library/Containers/com.aydintiritoglu.scouting1072-mac/Data/Library/Application Support/com.aydintiritoglu.scouting1072-mac/data.csv"
var averagesURLString = "~/Library/Containers/com.aydintiritoglu.scouting1072-mac/Data/Library/Application Support/com.aydintiritoglu.scouting1072-mac/averages.csv"
var robotImageDirString = "/Library/Containers/com.aydintiritoglu.scouting1072-mac/Data/Library/Application Support/com.aydintiritoglu.scouting1072-mac/robots/"
var dataReady = false
let prefixString = ["Team Number,Match Number,Username,Team Color,Starting Position,Preload,Ship Preload,Low Cargo,Low Hatch Panels,Mid Cargo,Mid Hatch Panels,High Cargo,High Hatch Panels,Defense Time,Dropped Pieces,Fouls,Bricked?,Climb Level,Was Assisted?,Assisted A Climb?,Defense Level,Comments\n", "Scouter,Match Number,Comments\n", "Scouter,Match Number,Comments\n", "Scouter,Match Number,Teams,Comment 1,Comment 2,Comment 3,Comment 4,Comment 5,Comment 6\n", "Scouter,Match Number,Teams,Fouls 1,Fouls 2,Fouls 3,Fouls 4,Fouls 5,Fouls 6,Yellow Cards,Red Cards,Comments\n"]
var graphsWindow : NSWindowController!
var newDataSetWindow : NSWindowController!
var specialDataWindow : NSWindowController!

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBAction func openGraphs(_ sender: Any) {
        graphsWindow = mainStoryboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("graphWindowController")) as? NSWindowController
        graphsWindow?.showWindow(nil)
    }
    
    @IBAction func openSpecialData(_ sender: Any) {
        specialDataWindow = mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("specialDataWindowController")) as? NSWindowController
        specialDataWindow?.showWindow(nil)
    }
    
    @IBAction func openNewDataSet(_ sender: Any) {
        newDataSetWindow = mainStoryboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("newDataSetWIndowController")) as? NSWindowController
        newDataSetWindow?.showWindow(nil)
    }
    
    @IBAction func importCSV(_ sender: Any) {
        if let newCSVURL = NSOpenPanel().selectURL {
            if let dataString = try? String(contentsOfFile: newCSVURL.path, encoding: .utf8) {
                if dataString.hasPrefix(prefixString[0]) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM-dd-yyyy-HH.mm.ss"
                    let dateString = formatter.string(from: Date())
                    let backupURLString = dataURLString.components(separatedBy: "/").dropLast().joined(separator: "/").appending("/data-\(dateString).csv")
                    if let currentDataString = try? String(contentsOfFile: csvURL.path, encoding: .utf8) {
                        FileManager.default.createFile(atPath: backupURLString, contents: currentDataString.data(using: .utf8)!, attributes: nil)
                    }
                    do {
                        try dataString.write(toFile: dataURLString, atomically: true, encoding: .utf8)
                    } catch {
                        FileManager.default.createFile(atPath: dataURLString, contents: (prefixString[0] + dataString).data(using: .utf8)!, attributes: nil)
                    }
                    loadData(from: csvURL)
                }
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var dataURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        dataURL.appendPathComponent("com.aydintiritoglu.scouting1072-mac/")
        try? FileManager.default.createDirectory(at: dataURL, withIntermediateDirectories: false, attributes: nil)
        averagesURLString = dataURL.appendingPathComponent("averages.csv").path
        robotImageDirString = dataURL.appendingPathComponent("robots").path + "/"
        let rootURL = dataURL
        dataURL.appendPathComponent("data.csv")
        dataURLString = dataURL.path
        csvURL = dataURL
        if !FileManager.default.fileExists(atPath: dataURLString) {
            FileManager.default.createFile(atPath: dataURLString, contents: prefixString[0].data(using: .utf8)!, attributes: nil)
        }
        assistantURL = rootURL.appendingPathComponent("assistant.csv")
        strategyURL = rootURL.appendingPathComponent("strategy.csv")
        defenseURL = rootURL.appendingPathComponent("defense.csv")
        foulsURL = rootURL.appendingPathComponent("fouls.csv")
        for (i, s) in ["assistant", "strategy", "defense", "fouls"].enumerated() {
            let urlPath = rootURL.appendingPathComponent("\(s).csv").path
            if !FileManager.default.fileExists(atPath: urlPath) {
                FileManager.default.createFile(atPath: urlPath, contents: prefixString[i + 1].data(using: .utf8)!, attributes: nil)
            }
        }
        print(dataURLString)
        loadData(from: dataURL)
        loadSpecialData(from: assistantURL, type: .assistant)
        loadSpecialData(from: strategyURL, type: .strategy)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}
