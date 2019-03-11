//
//  EmojiCollectionViewCell.swift
//  EmojiArt
//
//  Created by 唐小雨 on 2019/2/27.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var emojiLabel: UILabel! { didSet{ emojiLabel.backgroundColor = nil } }
}
