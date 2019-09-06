//
//  DataHandling.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 2/4/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Foundation
import Cocoa

extension NSOpenPanel {
    var selectURL: URL? {
        title = "Select CSV"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["csv"]
        return runModal() == .OK ? urls.first : nil
    }
    
    var selectURLs: [URL]? {
        title = "Select Images"
        allowsMultipleSelection = true
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["csv"]
        return runModal() == .OK ? urls : nil
    }
}

var fullData : [Int : [ScoutingData]] = [:] {
    didSet {
        var commentTmp : [Int : [String : String]] = [:]
        for (team, data) in fullData {
            for d in data {
                commentTmp[team, default: [:]][d.comments] = d.scouter
            }
        }
        comments = commentTmp
        commentsTableGlobal.reloadData()
    }
}

var assistantData : [Int: AssistantScoutingData] = [:]
var strategyData : [Int: StrategyScoutingData] = [:]
var defenseData : [Int: DefenseScoutingData] = [:]
var foulsData : [Int: FoulsScoutingData] = [:]

var comments : [Int : [String : String]] = [:]
var averages : [Int : [(value: Double, amount: Int)]] = [:]
var climbData : [Int : [Int]] = [:]
var mostOftenClimb : [Int : Int] = [:]
var startData : [Int : [Int]] = [:]
var mostOftenStart : [Int : Int] = [:]
var averagedMatches : [Int : [Int]] = [:]
var discrepantRounds : [Int : [Int]] = [:] {
    didSet {
        warningButton.isHidden = discrepantRounds.count <= 0
    }
}

func loadData(from dataURL: URL) {
    fullData = [:]
    currentTeam = 0
    teams = []
    if let dataString = try? String(contentsOfFile: dataURL.path, encoding: .utf8) {
        if !dataString.isEmpty {
            for row in dataString.components(separatedBy: "\n").dropLast().dropFirst() {
                let dataArray = row.components(separatedBy: ",")
                let teamNumber = Int(dataArray[0])!
                let matchNumber = Int(dataArray[1])!
                let scouter = dataArray[2]
                let teamColor = dataArray[3] == TeamColor.blue.description ? TeamColor.blue : TeamColor.red
                
                var startPos : StartPosition = .noShow
                switch dataArray[4] {
                case "Level 1": startPos = .leftBottom
                case "Level 2": startPos = .leftTop
                default: break
                }
                
                var preload : GamePiece!
                switch dataArray[5] {
                case "Hatch Panel": preload = .hatchPanel
                case "Cargo": preload = .cargo
                default: break
                }
                
                var shipPreload : [GamePiece] = []
                
                let beginning = [String(dataArray[6].dropFirst())]
                let middle = dataArray[7...10].map { String($0.dropFirst()) }
                let end = [String(dataArray[11].dropFirst().dropLast())]
                for p in beginning + middle + end {
                    switch p {
                    case "Hatch Panel": shipPreload.append(.hatchPanel)
                    case "Cargo": shipPreload.append(.cargo)
                    default: break
                    }
                }
                
                let lowCargo = Int(dataArray[12])!
                let lowHatches = Int(dataArray[13])!
                let midCargo = Int(dataArray[14])!
                let midHatches = Int(dataArray[15])!
                let highCargo = Int(dataArray[16])!
                let highHatches = Int(dataArray[17])!
                
                let defense = Int(dataArray[18])!
                let droppedPieces = Int(dataArray[19])!
                let fouls = Int(dataArray[20])!
                
                let bricked = dataArray[21] == "true"
                let climbLevel = Int(dataArray[22])!
                let wasAssisted = dataArray[23] == "true"
                let assistedClimb = dataArray[24] == "true"
                let defenseLevel = Int(dataArray[25])!
                let comments = row.components(separatedBy: "\"").count >= 4 ? row.components(separatedBy: "\"")[3] : dataArray[26]
                
                let data = ScoutingData(teamNumber: teamNumber, matchNumber: matchNumber, scouter: scouter, teamColor: teamColor, startPosition: startPos, preload: preload, shipPreload: shipPreload, lowCargo: lowCargo, lowHatches: lowHatches, midCargo: midCargo, midHatches: midHatches, highCargo: highCargo, highHatches: highHatches, defending: defense, droppedPieces: droppedPieces, fouls: fouls, bricked: bricked, climbLevel: climbLevel, wasAssisted: wasAssisted, assistedClimb: assistedClimb, defenseLevel: defenseLevel, comments: comments, fabricated: false)
                
                if let _ = fullData[data.teamNumber] {
                    fullData[data.teamNumber]!.append(data)
                } else {
                    fullData[data.teamNumber] = [data]
                }
            }
            for d in fullData.values {
                for data in d {
                    reAverage(usingData: data)
                }
            }
            currentTeam = teams.sorted().first ?? 0
            dataReady = true
        }
    }
}

func loadSpecialData(from dataURL: URL, type: SpecialScanType) {
    if let dataString = try? String(contentsOfFile: dataURL.path, encoding: .utf8) {
        if !dataString.isEmpty {
            for row in dataString.components(separatedBy: "\n").dropLast().dropFirst() {
                let dataArray = row.components(separatedBy: ",")
                switch type {
                case .assistant:
                    let scouter = dataArray[0]
                    let matchNumber = Int(dataArray[1]) ?? 0
                    let comments = row.components(separatedBy: "\"")[1]
                    
                    let newEntry = AssistantScoutingData(scouter: scouter, matchNumber: matchNumber, comments: comments)
                    assistantData[matchNumber] = newEntry
                case .strategy:
                    let scouter = dataArray[0]
                    let matchNumber = Int(dataArray[1]) ?? 0
                    let comments = row.components(separatedBy: "\"")[1]
                    
                    let newEntry = StrategyScoutingData(scouter: scouter, matchNumber: matchNumber, comments: comments)
                    strategyData[matchNumber] = newEntry
                default: break
                }
            }
            assistantSearchData = Array(assistantData.values).sorted { $0.matchNumber < $1.matchNumber }
            strategySearchData = Array(strategyData.values).sorted { $0.matchNumber < $1.matchNumber }
        }
    }
    print(assistantData)
}

func loadAverages() {
    if !FileManager.default.fileExists(atPath: averagesURLString) {
        FileManager.default.createFile(atPath: averagesURLString, contents: "".data(using: .utf8)!, attributes: nil)
    }
    if let averagesString = try? String(contentsOfFile: averagesURLString, encoding: .utf8) {
        if !averagesString.isEmpty {
            for row in averagesString.components(separatedBy: "\n").dropLast() {
                let team = Int(row.components(separatedBy: ",")[0])!
                teams.append(team)
                var infoArray : [(value: Double, amount: Int)] = []
                for rowItem in row.components(separatedBy: ",").dropFirst() {
                    let value = Double(rowItem.components(separatedBy: ":")[0])!
                    let amount = Int(rowItem.components(separatedBy: ":")[1])!
                    infoArray.append((value: value, amount: amount))
                }
                averages[team] = infoArray
            }
        }
    }
}

func reAverage(usingData data: ScoutingData) {
    if !teams.contains(data.teamNumber) { teams.append(data.teamNumber) }
    if data.startPosition == .noShow { return }
    if (averagedMatches[data.teamNumber] ?? []).contains(data.matchNumber) {
        if !(discrepantRounds[data.teamNumber]?.contains(data.matchNumber) ?? false) {
            let matchData : [ScoutingData] = fullData[data.teamNumber]!.filter { $0.matchNumber == data.matchNumber }.map {
                var d = $0
                d.comments = ""
                d.fouls = 0
                d.droppedPieces = 0
                d.defending = 0
                return d
            }
            for (i, d) in matchData.enumerated() {
                if i + 1 < matchData.count {
                    for n in (i + 1)..<matchData.count {
                        if matchData[n] != d {
                            if let _ = discrepantRounds[data.teamNumber] {
                                discrepantRounds[data.teamNumber]!.append(data.matchNumber)
                            } else {
                                discrepantRounds[data.teamNumber] = [data.matchNumber]
                            }
                            return
                        }
                    }
                }
            }
        }
    } else {
        if let teamData = averages[data.teamNumber] {
            // start and climb bc they're special snowflakes
            let start = averageStart(position: data.startPosition)
            if let _ = startData[data.teamNumber] {
                startData[data.teamNumber]!.append(start)
            } else {
                startData[data.teamNumber] = [start]
            }
            mostOftenStart[data.teamNumber] = mostCommonInt(in: startData[data.teamNumber]!)
            
            let climb = data.climbLevel
            if let _ = climbData[data.teamNumber] {
                climbData[data.teamNumber]!.append(climb)
            } else {
                climbData[data.teamNumber] = [climb]
            }
            mostOftenClimb[data.teamNumber] = mostCommonInt(in: climbData[data.teamNumber]!)
            // other averages
            var newAverages : [(value: Double, amount: Int)] = []
            let newData : [(value: Double, amount: Int)] = [(value: Double(data.lowCargo), amount: 1), (value: Double(data.midCargo), amount: 1), (value: Double(data.highCargo), amount: 1), (value: Double(data.lowHatches), amount: 1), (value: Double(data.midHatches), amount: 1), (value: Double(data.highHatches), amount: 1), (value: Double(data.climbLevel), amount: 1), (value: data.wasAssisted ? 1 : 0, amount: 1), (value: data.assistedClimb ? 1 : 0, amount: 1), (value: data.preload == .cargo ? 1 : 0, amount: 1), (value: Double(averageStart(position: data.startPosition)), amount: 1), (value: Double(data.defending), amount: 1), (value: Double(data.defenseLevel), amount: 1)]
            for (i, average) in teamData.enumerated() {
                newAverages.append((value: Double(average.value * Double(average.amount) + newData[i].value) / Double(average.amount + 1), amount: (average.amount + 1)))
            }
            averages[data.teamNumber] = newAverages
        } else {
            let start = averageStart(position: data.startPosition)
            if let _ = startData[data.teamNumber] {
                startData[data.teamNumber]!.append(start)
            } else {
                startData[data.teamNumber] = [start]
            }
            mostOftenStart[data.teamNumber] = mostCommonInt(in: startData[data.teamNumber]!)
            
            let climb = data.climbLevel
            if let _ = climbData[data.teamNumber] {
                climbData[data.teamNumber]!.append(climb)
            } else {
                climbData[data.teamNumber] = [climb]
            }
            mostOftenClimb[data.teamNumber] = mostCommonInt(in: climbData[data.teamNumber]!)
            averages[data.teamNumber] = [(value: Double(data.lowCargo), amount: 1), (value: Double(data.midCargo), amount: 1), (value: Double(data.highCargo), amount: 1), (value: Double(data.lowHatches), amount: 1), (value: Double(data.midHatches), amount: 1), (value: Double(data.highHatches), amount: 1), (value: Double(data.climbLevel), amount: 1), (value: data.wasAssisted ? 1 : 0, amount: 1), (value: data.assistedClimb ? 1 : 0, amount: 1), (value: data.preload == .cargo ? 1 : 0, amount: 1), (value: Double(averageStart(position: data.startPosition)), amount: 1), (value: Double(data.defending), amount: 1), (value: Double(data.defenseLevel), amount: 1)]
        }
        if let _ = averagedMatches[data.teamNumber] {
            averagedMatches[data.teamNumber]!.append(data.matchNumber)
        } else {
            averagedMatches[data.teamNumber] = [data.matchNumber]
        }
        //writeAverages()
    }
}

func mostCommonInt(in array: [Int]) -> Int {
    let sorted = array.sorted { $0 > $1 }
    var i = -1
    var prev = -1
    var maxArray : [Int] = []
    var indexMap : [Int : Int] = [:]
    
    for int in sorted {
        if int == prev {
            maxArray[i] += 1
        } else {
            prev = int
            i += 1
            maxArray.append(1)
            indexMap[i] = int
        }
    }
    let mostCommonIndex = maxArray.firstIndex(of: maxArray.max()!)
    return indexMap[mostCommonIndex!]!
}

func averageStart(position: StartPosition) -> Int {
    switch position {
    case .leftBottom, .middleBottom, .rightBottom:
        return 0
    case .leftTop, .rightTop:
        return 1
    case .noShow:
        return 2
    }
}

func writeAverages() {
    var writeString = String()
    for (key, value) in averages {
        writeString.append("\(key),")
        for item in value {
            writeString.append("\(item.value):\(item.amount),")
        }
        writeString = String(writeString.dropLast())
        writeString.append("\n")
    }
    do {
        try writeString.write(toFile: averagesURLString, atomically: true, encoding: .utf8)
    } catch {
        print(error)
    }
}
