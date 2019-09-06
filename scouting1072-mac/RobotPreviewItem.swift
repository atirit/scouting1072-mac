//
//  RobotPreviewItem.swift
//  scouting1072-mac
//
//  Created by Aydin Tiritoglu on 3/9/19.
//  Copyright © 2019 Aydin Tiritoglu. All rights reserved.
//

import Cocoa
import Quartz

class RobotPreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL! {
        get {
            let team = (shouldUseSearchTeams ? searchTeams : teams).sorted()[currentRow]
            if FileManager.default.fileExists(atPath: robotImageDirString + "\(team).jpeg") {
                return URL(fileURLWithPath: robotImageDirString + "\(team).jpeg")
            } else {
                return URL(fileURLWithPath: robotImageDirString + "254old.png")
            }
        }
    }
}
