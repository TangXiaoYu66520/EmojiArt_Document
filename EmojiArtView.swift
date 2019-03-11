//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by 唐小雨 on 2019/2/27.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

class EmojiArtView: UIImageView {
    
    func setUp() -> Void {
        addInteraction(UIDropInteraction(delegate: self))
        isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setUp()
    }
    
}


// MARK: - UIDropInteractionDelegate

extension EmojiArtView: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        session.loadObjects(ofClass: NSAttributedString.self) { [weak self] (items) in
            if let attributedStrings = items as? [NSAttributedString] , self != nil{
                let location = session.location(in: self!)
                let label = UILabel()
                label.attributedText = attributedStrings.first
                label.sizeToFit()
                label.backgroundColor = nil
                label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self?.addBorder(tapGesture:))))
                self?.addSubview(label)
                label.center = location
            }
        }
    }
    
    @objc func addBorder(tapGesture: UITapGestureRecognizer) -> Void {
        if let tapView = tapGesture.view {
            print("1")
            tapView.layer.borderColor = UIColor.black.cgColor
            tapView.layer.borderWidth = 3.0
        }
    }

}
