//
//  CollectionViewDragDelegate.swift
//  EmojiArt
//
//  Created by 唐小雨 on 2019/2/28.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

extension EmojiArtViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    //MARK: - drop

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if let indexPath = destinationIndexPath, indexPath.section == 1 {
            let isSelf = (session.localDragSession?.localContext as? UICollectionView) === collectionView
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        }
        else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    emojis.remove(at: sourceIndexPath.item)
                    emojis.insert(attributedString.string, at: destinationIndexPath.item)

                    collectionView.performBatchUpdates( {
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else{
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: Identifier.placeHolder))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { [weak self] (provider, error) in
                    if let attributeString = (provider as? NSAttributedString)?.mutableCopy() as? NSMutableAttributedString {
                        attributeString.setAttributes([NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .body).withSize(64)], range: NSRange(location: 0, length: attributeString.length))
                        DispatchQueue.main.async {
                            placeholderContext.commitInsertion(dataSourceUpdates: { (indexPath) in
                                self?.emojis.insert(attributeString.string, at: indexPath.item)
                            })
                        }
                    }else {
                        placeholderContext.deletePlaceholder()
                    }
                }
            }
        }
    }
    
    
    //MARK: - drag
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    func dragItems(at indexpath: IndexPath) -> [UIDragItem] {
        if !addingEmoji, let attributeString = (collectionView.cellForItem(at: indexpath) as? EmojiCollectionViewCell)?.emojiLabel?.attributedText {
            let item = UIDragItem(itemProvider: NSItemProvider(object: attributeString))
            item.localObject = attributeString
            return [item]
        }else {
            return []
        }
    }
    
    
}
