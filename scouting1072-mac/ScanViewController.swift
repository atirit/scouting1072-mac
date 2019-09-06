//
//  ScanViewController.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 1/18/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa
import ZXingObjC

var scanWindow: NSWindowController!

func stringToBinaryString (_ myString: String) -> String {
    let characterArray = [Character](myString)
    let asciiArray = characterArray.map { String($0).unicodeScalars.first!.value }
    let binaryArray = asciiArray.map ({ String($0, radix: 2)})
    let r = binaryArray.reduce("", {$0 + " " + $1})
    return r
}

let commentEncoding : [String : String] = ["100": " ", "010": ",", "001": ".", "1011": "e", "0001": "t", "11111": "a", "11100": "o", "11010": "n", "11001": "i", "10101": "s", "10100": "r", "01111": "h", "00001": "d", "00000": "l", "011101": "u", "011100": "c", "011010": "m", "011001": "f", "011000": "w", "1111011": "g", "1111010": "9", "1111001": "2", "1111000": "1", "1110111": "4", "1110110": "3", "1110101": "6", "1110100": "5", "1101111": "8", "1101110": "7", "1101101": "0", "1101100": "y", "1100001": "p", "1100000": "b", "0110110": "v", "11000101": ";", "11000100": "(", "01101111": "-", "01101110": "k", "110001110": "?", "110001101": "!", "110001100": ":", "11000111111": "x", "11000111110": "j", "11000111101": "q", "11000111100": "z"]
let oldUsernames = ["22DennisG", "22AnishP", "22BobbyW", "22ZachC", "22AdheetG", "22KailashR", "22PranavV", "22AustinW", "19RahulG", "22PrakritJ", "22PranavG", "22ChiragK", "22DanielF", "22AnirudhK", "22RohanR", "21AydinT", "21ArthurJ", "20JackJ", "20NealS", "21EthanS", "22DawsonC", "22HarshD", "22ShahzebL", "22AlexL", "19AndrewC", "19DJM", "19PuneetN", "19CharlesP", "20SahilG", "20JatinK", "19ChristopherL", "20RohanS", "22EthanC", "20FinnF", "20SanjayR", "19NemoY", "19RyanA", "20QuentinC", "19JoelM", "19RithvikP", "21ChloeA", "21AnkitaK", "22SarahL", "22KateL", "21HariB", "22AngieJ", "22AliviaL", "22KateO", "21AngelaC", "21AditiV", "22AimeeW", "22GloriaZ", "19CarlG", "guest"]
let usernames = ["22ShahzebL", "21ChloeA", "22PranavG", "20NealS", "19RahulG", "22ChiragK", "21HariB", "19JoelM", "21EthanS", "19DjM", "19PuneetN", "22AdheetG", "21AditiV", "19AndrewC", "19ChristopherL", "20FinnF", "21AngelaC", "20SanjayR", "19CarlG", "20JatinK", "22EthanC", "22KateO", "19CharlesP", "22GloriaZ", "22AngieJ", "22PrakritJ", "21ArthurJ", "20RohanS", "21AydinT", "21AnkitaK", "19RyanA", "22KailashR", "22AnishP", "22AliviaL", "20QuentinC", "22ZachC", "22AustinW", "22DennisG", "22ArnavG", "22DawsonC", "22PranavV", "22AlexL", "22RaymondX", "22BobbyW", "22WillY", "22AimeeW", "20NashM", "20SahilG", "22HarshD", "22RohanR", "guest"]

//let fouls = ["G3": "", "G9": "", "G10": "", "G13": "", "G16": "", "G18": "", "G20": "", "UN": "", "G4": "", "G5": "", "G6": "", "G7": "", "G11": "", "G12": "", "H10": ""]
let listOfFouls = ["G3", "G9", "G10", "G13", "G16", "G18", "G20", "UN", "G4", "G5", "G6", "G7", "G11", "G12", "H10"]

enum SpecialScanType {
    case strategy
    case assistant
    case defense
    case fouls
}

enum StartPosition: Int, CustomStringConvertible, Equatable {
    var description: String {
        switch self {
        case .leftTop, .rightTop: return "Level 2"
        case .leftBottom, .middleBottom, .rightBottom: return "Level 1"
        case .noShow: return "No-Show"
        }
    }
    
    case leftTop
    case leftBottom
    case middleBottom
    case rightTop
    case rightBottom
    case noShow
}

enum GamePiece: Int, CustomStringConvertible, Equatable {
    case hatchPanel
    case cargo
    
    var description: String {
        switch self {
        case .hatchPanel: return "Hatch Panel"
        case .cargo: return "Cargo"
        }
    }
}

enum TeamColor: Int, CustomStringConvertible, Equatable {
    case red
    case blue
    
    var description: String {
        switch self {
        case .red: return "Red"
        case .blue: return "Blue"
        }
    }
}

struct ScoutingData: CustomStringConvertible, Equatable {
    // team/match/scouter info
    var teamNumber: Int
    var matchNumber: Int
    var scouter: String
    var teamColor: TeamColor
    
    // pregame
    var startPosition: StartPosition
    var preload: GamePiece
    var shipPreload: [GamePiece]
    
    // game pieces
    var lowCargo: Int
    var lowHatches: Int
    var midCargo: Int
    var midHatches: Int
    var highCargo: Int
    var highHatches: Int
    
    // seconds spent on defense
    var defending: Int
    
    // errors
    var droppedPieces: Int
    var fouls: Int
    var bricked: Bool
    
    // endgame
    var climbLevel: Int
    var wasAssisted: Bool
    var assistedClimb: Bool
    var defenseLevel: Int
    
    // comments
    var comments: String
    
    var fabricated: Bool
    
    var description: String {
        return """
        ————————————————————————————————
        Team Number: \(self.teamNumber)
        Match Number: \(self.matchNumber)
        Scouter: \(self.scouter)
        Team Color: \(self.teamColor)
        
        Start Level: \(averageStart(position: self.startPosition) == 2 ? "No-Show" : String(averageStart(position: self.startPosition) + 1))
        Preload: \(self.preload)
        Ship Preload: \(self.shipPreload.description.dropFirst().dropLast())
        
        Low Cargo: \(self.lowCargo)
        Low Hatches: \(self.lowHatches)
        Mid Cargo: \(self.midCargo)
        Mid Hatches: \(self.midHatches)
        High Cargo: \(self.highCargo)
        High Hatches: \(self.highHatches)
        
        Defense Time: \(self.defending)
        Dropped Pieces: \(self.droppedPieces)
        Fouls: \(self.fouls)
        Bricked: \(self.bricked)
        
        Climb Level: \(self.climbLevel)
        Was Assisted: \(self.wasAssisted)
        Assisted A Climb: \(self.assistedClimb)
        Defense Stars: \(self.defenseLevel)
        
        \(self.comments.isEmpty ? "No Comments" : "Comments: \(self.comments)")\(self.fabricated ? "\nFabricated: true" : "")
        """
    }
}

struct AssistantScoutingData: CustomStringConvertible, Equatable {
    var scouter: String
    var matchNumber: Int
    var comments: String
    
    var description: String {
        return """
        ————————————————————————————————
        ASSISTANT DATA
        Scouter: \(self.scouter)
        Match Number: \(self.matchNumber)
        Comments: \(self.comments)
        """
    }
}

struct StrategyScoutingData: CustomStringConvertible, Equatable {
    var scouter: String
    var matchNumber: Int
    var comments: String
    
    var description: String {
        return """
        ————————————————————————————————
        STRATEGY DATA
        Scouter: \(self.scouter)
        Match Number: \(self.matchNumber)
        Comments: \(self.comments)
        """
    }
}

struct DefenseScoutingData: CustomStringConvertible, Equatable {
    var scouter: String
    var matchNumber: Int
    var comments: [Int: String]
    
    var description: String {
        var str = """
        ————————————————————————————————
        DEFENSE DATA
        Scouter: \(self.scouter)
        Match Number: \(self.matchNumber)
        """
        
        for (k, v) in comments {
            str.append("\n\nTeam \(k)\nComments: \(v)")
        }
        
        return str
    }
}

struct FoulsScoutingData: CustomStringConvertible, Equatable {
    var scouter: String
    var matchNumber: Int
    var teams: [Int]
    var fouls: [Int: [String]]
    var yellowCards: [Int]
    var redCards: [Int]
    var comments: String
    
    var description: String {
        return """
        ————————————————————————————————
        FOULS DATA
        Scouter: \(self.scouter)
        Match Number: \(self.matchNumber)
        Teams: \(self.teams)
        Fouls: \(self.fouls)
        Yellow Cards: \(self.yellowCards)
        Red Cards: \(self.redCards)
        Comments: \(self.comments)
        """
    }
}

class ScanViewController: NSViewController, ZXCaptureDelegate {
    var zxcapture = ZXCapture()
    var captureSizeTransform = CGAffineTransform()
    var captureSession : AVCaptureSession? = AVCaptureSession()
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var qrData = Data()
    var processing = false
    
    func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
        // if processing { return }
        if result.barcodeFormat != kBarcodeFormatQRCode { return }
        if readyButton.isEnabled { return }
        
        if let bytes = result.resultMetadata.object(forKey: kResultMetadataTypeByteSegments.rawValue) as? NSArray {
            let byteArray = bytes[0] as! ZXByteArray
            let data = Data(bytes: UnsafeRawPointer(byteArray.array), count: Int(byteArray.length))
            var bitArray : [UInt8] = []
            let bitString = stringToBinaryString(String(data: data, encoding: .isoLatin1)!)
            for b in bitString.components(separatedBy: " ").dropFirst() {
                let byte = String(repeating: "0", count: 8 - b.count) + b
                for c in byte {
                    bitArray.append(UInt8(String(c))!)
                }
            }
            print(bitArray.description.components(separatedBy: ", ").joined().dropFirst().dropLast())
            if isRescanning {
                bitArray = Array(bitArray.dropFirst(6).dropLast(2))
                print("modified:")
                print(bitArray.description.components(separatedBy: ", ").joined().dropFirst().dropLast())
            }
            //parseData(bitArray)
            let magicBits : UInt8 = (bitArray[0] << 2) + (bitArray[1] << 1) + bitArray[2]
            print(magicBits)
            var specialScanType : SpecialScanType? = nil
            switch magicBits {
            case 1: specialScanType = .assistant
            case 2: specialScanType = .strategy
            case 3: specialScanType = .defense
            case 4: specialScanType = .fouls
            default: break
            }
            bitArray = Array(bitArray.dropFirst(3))
            if let type = specialScanType {
                parseSpecialData(bitArray, type: type)
            } else {
                parseData(bitArray)
            }
        }
    }
    
    func parseSpecialData(_ bitArray: [UInt8], type: SpecialScanType) {
        switch type {
        case .strategy, .assistant:
            var i = 5
            var scoutNumber : Int = 0
            for b in bitArray[0...5] {
                scoutNumber += Int(b) << i
                i -= 1
            }
            let scouter = usernames[scoutNumber]
            var matchNumber : Int = 0
            i = 6
            for b in bitArray[6...12] {
                matchNumber += Int(b) << i
                i -= 1
            }
            i = 0
            var t = ""
            var comments = ""
            for b in bitArray[13..<bitArray.count] {
                t.append(String(b))
                if let c = commentEncoding[t] {
                    if c == "(" && i == 1 {
                        comments.append(")")
                        i = 0
                    } else {
                        if c == "(" {
                            i = 1
                        }
                        comments.append(c)
                    }
                    t = ""
                }
            }
            if type == .assistant {
                let newData = AssistantScoutingData(scouter: scouter, matchNumber: matchNumber, comments: comments)
                print(newData)
                assistantData[newData.matchNumber] = newData
                let csvString = "\(newData.scouter),\(newData.matchNumber),\"\(newData.comments)\"\n"
                if let csvFile = FileHandle(forWritingAtPath: assistantURL.path) {
                    csvFile.seekToEndOfFile()
                    csvFile.write(csvString.data(using: .utf8)!)
                    csvFile.closeFile()
                }
            } else {
                let newData = StrategyScoutingData(scouter: scouter, matchNumber: matchNumber, comments: comments)
                print(newData)
                strategyData[newData.matchNumber] = newData
                let csvString = "\(newData.scouter),\(newData.matchNumber),\"\(newData.comments)\"\n"
                if let csvFile = FileHandle(forWritingAtPath: strategyURL.path) {
                    csvFile.seekToEndOfFile()
                    csvFile.write(csvString.data(using: .utf8)!)
                    csvFile.closeFile()
                }
            }
        case .defense:
            var i = 5
            var scoutNumber : Int = 0
            for b in bitArray[0...5] {
                scoutNumber += Int(b) << i
                i -= 1
            }
            let scouter = usernames[scoutNumber]
            var matchNumber : Int = 0
            i = 6
            for b in bitArray[6...12] {
                matchNumber += Int(b) << i
                i -= 1
            }
            var teamNumbers : [Int] = []
            for o in 1...4 {
                var teamNumber : Int = 0
                i = 12
                for b in bitArray[(12 * o + o)...(12 * (o + 1) + o)] {
                    teamNumber += Int(b) << i
                    i -= 1
                }
                teamNumbers.append(teamNumber)
            }
            i = 0
            var t = ""
            var comment = ""
            var comments : [String] = []
            for b in bitArray[65..<bitArray.count] {
                t.append(String(b))
                if let c = commentEncoding[t] {
                    if c == "(" && i == 1 {
                        comment.append(")")
                        i = 0
                    } else if c == "!" {
                        comments.append(comment)
                        comment = ""
                    } else {
                        if c == "(" {
                            i = 1
                        }
                        comment.append(c)
                    }
                    t = ""
                }
            }
            comments.append(comment)
            var teamComments : [Int : String] = [:]
            for (i, t) in teamNumbers.enumerated() {
                if t != 0 {
                    if i < comments.count {
                        teamComments[t] = comments[i]
                    } else {
                        teamComments[t] = ""
                    }
                }
            }
            let newData = DefenseScoutingData(scouter: scouter, matchNumber: matchNumber, comments: teamComments)
            print(newData)
            defenseData[newData.matchNumber] = newData
            var csvString = "\(newData.scouter),\(newData.matchNumber),\""
            var commentsString = "\""
            for (i, t) in teamNumbers.enumerated() {
                if t != 0 {
                    csvString.append("\(t),")
                    commentsString.append("\(newData.comments[i] ?? "")\",\"")
                }
            }
            csvString = String(csvString.dropLast())
            commentsString = String(commentsString.dropLast(2))
            csvString.append("\",\(commentsString)\n")
            if let csvFile = FileHandle(forWritingAtPath: defenseURL.path) {
                csvFile.seekToEndOfFile()
                csvFile.write(csvString.data(using: .utf8)!)
                csvFile.closeFile()
            }
        case .fouls:
            var i = 5
            var scoutNumber : Int = 0
            for b in bitArray[0...5] {
                scoutNumber += Int(b) << i
                i -= 1
            }
            let scouter = usernames[scoutNumber]
            var matchNumber : Int = 0
            i = 6
            for b in bitArray[6...12] {
                matchNumber += Int(b) << i
                i -= 1
            }
            var teamNumbers : [Int] = []
            for o in 1...6 {
                var teamNumber : Int = 0
                i = 12
                for b in bitArray[(12 * o + o)...(12 * (o + 1) + o)] {
                    teamNumber += Int(b) << i
                    i -= 1
                }
                teamNumbers.append(teamNumber)
            }
            i = 0
            var dataFouls : [Int: [String]] = [:]
            var nextIndex = 91 // because the data section is of arbitrary length, we need to know where to continue from
            var chunkSize = 8
            let foulsBitArray = Array(bitArray[91...])
            let foulChunks = stride(from: 0, to: foulsBitArray.count, by: chunkSize).map { Array(foulsBitArray[$0..<min($0 + chunkSize, foulsBitArray.count)]) }
            for a in foulChunks {
                let bitString = a.map { return String($0) }.joined()
                if bitString.hasPrefix("111") {
                    nextIndex += 3
                    break
                }
                nextIndex += 8
                let teamIndex = (a[0] << 2) + (a[1] << 1) + a[2]
                let foulIndex = (a[3] << 3) + (a[4] << 2) + (a[5] << 1) + a[6]
                let techFoul = a[7] == 1 ? "1" : "0"
                let teamNumber = teamNumbers[Int(teamIndex)]
                let foul = listOfFouls[Int(foulIndex)]
                if let _ = dataFouls[teamNumber] {
                    dataFouls[teamNumber]!.append(techFoul + foul)
                } else {
                    dataFouls[teamNumber] = [techFoul + foul]
                }
            }
            chunkSize = 2
            let cardsArray = Array(bitArray[nextIndex...nextIndex + 11])
            let cardChunks = stride(from: 0, to: cardsArray.count, by: chunkSize).map { Array(cardsArray[$0..<min($0 + chunkSize, cardsArray.count)]) }
            var redCards: [Int] = []
            var yellowCards: [Int] = []
            for (i, a) in cardChunks.enumerated() {
                for (o, v) in a.enumerated() {
                    if v == 1 {
                        if o == 0 {
                            yellowCards.append(teamNumbers[i])
                        } else {
                            redCards.append(teamNumbers[i])
                        }
                    }
                }
            }
            i = 0
            var t = ""
            var comments = ""
            for b in bitArray[nextIndex + 12..<bitArray.count] {
                t.append(String(b))
                if let c = commentEncoding[t] {
                    if c == "(" && i == 1 {
                        comments.append(")")
                        i = 0
                    } else {
                        if c == "(" {
                            i = 1
                        }
                        comments.append(c)
                    }
                    t = ""
                }
            }
            let newData = FoulsScoutingData(scouter: scouter, matchNumber: matchNumber, teams: teamNumbers, fouls: dataFouls, yellowCards: yellowCards, redCards: redCards, comments: comments)
            print(newData)
            foulsData[newData.matchNumber] = newData
            var csvString = "\(newData.scouter),\(newData.matchNumber),\"\(String(teamNumbers.description.dropFirst().dropLast()))\",\""
            for t in teamNumbers {
                csvString.append("\(String(newData.fouls[t]?.description.dropFirst().dropLast() ?? ""))\",\"")
            }
            csvString.append("\(newData.yellowCards.description.dropFirst().dropLast())\",\"\(newData.redCards.description.dropFirst().dropLast())\",\"\(newData.comments)\"\n")
            if let csvFile = FileHandle(forWritingAtPath: foulsURL.path) {
                csvFile.seekToEndOfFile()
                csvFile.write(csvString.data(using: .utf8)!)
                csvFile.closeFile()
            }
        }
        readyButton.isEnabled = true
    }
    
    func parseData(_ bitArray: [UInt8]) {
        let startPosBits = (bitArray[0] << 2) + (bitArray[1] << 1) + bitArray[2]
        let startPos = StartPosition(rawValue: Int(startPosBits)) ?? .middleBottom
        let preload = GamePiece(rawValue: Int(bitArray[3])) ?? .hatchPanel
        var shipLoadArray : [GamePiece] = []
        for b in bitArray[4...9] {
            shipLoadArray.append(GamePiece(rawValue: Int(b)) ?? .hatchPanel)
        }
        let lowCargo = (bitArray[10] << 3) + (bitArray[11] << 2) + (bitArray[12] << 1) + bitArray[13]
        let lowHatches = (bitArray[14] << 3) + (bitArray[15] << 2) + (bitArray[16] << 1) + bitArray[17]
        let midCargo = (bitArray[18] << 2) + (bitArray[19] << 1) + bitArray[20]
        let midHatches = (bitArray[21] << 2) + (bitArray[22] << 1) + bitArray[23]
        let highCargo = (bitArray[24] << 2) + (bitArray[25] << 1) + bitArray[26]
        let highHatches = (bitArray[27] << 2) + (bitArray[28] << 1) + bitArray[29]
        var defense : UInt8 = 0
        var i = 7
        for b in bitArray[30...37] {
            defense += b << i
            i -= 1
        }
        var droppedPieces : UInt8 = 0
        i = 3
        for b in bitArray[38...41] {
            droppedPieces += b << i
            i -= 1
        }
        var fouls : UInt8 = 0
        i = 3
        for b in bitArray[42...45] {
            fouls += b << i
            i -= 1
        }
        let bricked = bitArray[46] == 1
        
        let climbLevel = (bitArray[47] << 1) + bitArray[48]
        let wasAssisted = bitArray[49] == 1
        let assistedClimb = bitArray[50] == 1
        var defenseLevel : Int = 0
        i = 2
            for b in bitArray[51...53] {
            defenseLevel += Int(b) << i
            i -= 1
        }
        defenseLevel = defenseLevel == 5 ? 0 : defenseLevel + 1
        var teamNumber : Int = 0
        i = 12
        for b in bitArray[54...66] {
            teamNumber += Int(b) << i
            i -= 1
        }
        var matchNumber : Int = 0
        i = 6
        for b in bitArray[67...73] {
            matchNumber += Int(b) << i
            i -= 1
        }
        let teamColor = TeamColor(rawValue: Int(bitArray[74]))!
        var scoutNumber : Int = 0
        i = 5
        print(bitArray[75...80])
        for b in bitArray[75...80] {
            scoutNumber += Int(b) << i
            i -= 1
        }
        let scouter = usernames[scoutNumber]
        i = 0
        var t = ""
        var comments = ""
        for b in bitArray[81..<bitArray.count] {
            t.append(String(b))
            if let c = commentEncoding[t] {
                if c == "(" && i == 1 {
                    comments.append(")")
                    i = 0
                } else {
                    if c == "(" {
                        i = 1
                    }
                    comments.append(c)
                }
                t = ""
            }
        }
        let tmpData = ScoutingData(teamNumber: teamNumber, matchNumber: matchNumber, scouter: scouter, teamColor: teamColor, startPosition: startPos, preload: preload, shipPreload: shipLoadArray, lowCargo: Int(lowCargo), lowHatches: Int(lowHatches), midCargo: Int(midCargo), midHatches: Int(midHatches), highCargo: Int(highCargo), highHatches: Int(highHatches), defending: Int(defense), droppedPieces: Int(droppedPieces), fouls: Int(fouls), bricked: bricked, climbLevel: Int(climbLevel), wasAssisted: wasAssisted, assistedClimb: assistedClimb, defenseLevel: defenseLevel, comments: comments, fabricated: false)
        let csvString = "\(tmpData.teamNumber),\(tmpData.matchNumber),\(tmpData.scouter),\(tmpData.teamColor),\(tmpData.startPosition),\(tmpData.preload),\"\(tmpData.shipPreload.description.dropFirst().dropLast())\",\(tmpData.lowCargo),\(tmpData.lowHatches),\(tmpData.midCargo),\(tmpData.midHatches),\(tmpData.highCargo),\(tmpData.highHatches),\(tmpData.defending),\(tmpData.droppedPieces),\(tmpData.fouls),\(tmpData.bricked),\(tmpData.climbLevel),\(tmpData.wasAssisted),\(tmpData.assistedClimb),\(tmpData.defenseLevel),\"\(tmpData.comments)\"\n"
        if let csvFile = FileHandle(forWritingAtPath: csvURL.path) {
            csvFile.seekToEndOfFile()
            csvFile.write(csvString.data(using: .utf8)!)
            csvFile.closeFile()
        }
        if let _ = fullData[tmpData.teamNumber] {
            fullData[tmpData.teamNumber]!.append(tmpData)
        } else {
            fullData[tmpData.teamNumber] = [tmpData]
        }
        print(tmpData)
        reAverage(usingData: tmpData)
        sidebarGlobal.reloadData()
        readyButton.isEnabled = true
    }
    
    override func viewWillDisappear() {
        zxcapture.delegate = nil
        zxcapture.stop()
        scanButton.isEnabled = true
    }
    
    override func viewWillAppear() {
        zxcapture.delegate = self
        zxcapture.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let zxcapture = ZXCapture()
        self.zxcapture = zxcapture
        zxcapture.camera = zxcapture.back()
        zxcapture.layer.frame = view.bounds
        view.layer = CALayer()
        view.layer?.addSublayer(zxcapture.layer)
    }
    
}
