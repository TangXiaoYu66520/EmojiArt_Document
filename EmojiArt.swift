//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by 唐小雨 on 2019/3/5.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

struct EmojiArt: Codable {
    var backgroundImageData: Data
    var emojis: [EmojiInfo]
    
    struct EmojiInfo: Codable {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    var jsonData: Data?{
        return try? JSONEncoder().encode(self)
    }
    
    init?(data: Data) {
        if let emojiArt = try? JSONDecoder().decode(EmojiArt.self, from: data) {
            self = emojiArt
        }
        else {
            return nil
        }
    }

    init(backgroundImageData: Data, emojis: [EmojiInfo] ) {
        self.backgroundImageData = backgroundImageData
        self.emojis = emojis
    }
}

