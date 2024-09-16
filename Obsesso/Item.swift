//
//  Item.swift
//  Obsesso
//
//  Created by Ege Çam on 16.09.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var type: String
    var title: String
    var videoURL: String
    var timestamp: Date
    
    init(type: String, title: String, videoURL: String, timestamp: Date) {
        self.type = type
        self.title = title
        self.videoURL = videoURL
        self.timestamp = timestamp
    }
}
