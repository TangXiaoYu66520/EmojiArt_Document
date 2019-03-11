//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by 唐小雨 on 2019/3/2.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!{ didSet{ textField.clearsOnBeginEditing = true}}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    var resignationHandler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
}
