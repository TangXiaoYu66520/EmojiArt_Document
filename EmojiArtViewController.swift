//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by 唐小雨 on 2019/2/27.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

extension EmojiArt.EmojiInfo {
    init?(label: UILabel) {
        if let attriburedText = label.attributedText, let font = attriburedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont{
            x = Int(label.center.x)
            y = Int(label.center.y)
            text = attriburedText.string
            size = Int(font.pointSize)
        }else{
            return nil
        }
        
    }
    
}

class EmojiArtViewController: UIViewController {
    lazy var emojiArtView = EmojiArtView()
    var emojis = "😚🥶🐒🐥🐞🐜🦀🙊🐬🍑🍎🥨🌽🏀🚜🚒🚂".map{ String($0) }
    
    //MARK: - Model
    var emojiArt: EmojiArt?{
        get {
            if let imageData = backgroundImage?.jpegData(compressionQuality: 1) {
                let emojis = emojiArtView.subviews.compactMap({ $0 as? UILabel}).compactMap({ EmojiArt.EmojiInfo(label: $0)})
                return EmojiArt(backgroundImageData: imageData, emojis: emojis)
            }
            else{
                return nil
            }
        }
        set {
            backgroundImage = nil
            emojiArtView.subviews.compactMap({ $0 as? UILabel}).forEach({$0.removeFromSuperview()})
            backgroundImage = UIImage(data: newValue?.backgroundImageData ?? Data())
            newValue?.emojis.forEach({
                let attributedText = NSAttributedString(string: $0.text, attributes: [.font : UIFont.preferredFont(forTextStyle: .body).withSize(CGFloat($0.size))])
                let center = CGPoint(x: $0.x, y: $0.y)
                
                let label = UILabel()
                label.attributedText = attributedText
                label.sizeToFit()
                emojiArtView.addSubview(label)
                label.center = center
            })
        }
    }
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var dropArea: UIView!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.dragInteractionEnabled = true
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
                scrollView.minimumZoomScale = 0.3
                scrollView.maximumZoomScale = 10
                scrollView.delegate = self
                scrollView.addSubview(emojiArtView)
        }
    }
    
    //MARK: - view controller life cycle
    
    var document: EmojiArtDocument!
    
    @IBAction func save(_ sender: UIBarButtonItem? = nil) {
        if let localEmojiArt = emojiArt{
            document?.emojiArt = localEmojiArt
//            document?.save(to: document.fileURL, for: .forCreating, completionHandler: nil)
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func Close(_ sender: UIBarButtonItem? = nil) {
        save()
        if document.emojiArt != nil {
            let imageRender = UIGraphicsImageRenderer(size: emojiArtView.bounds.size)
            let thumbnail = imageRender.image { (context) in
                emojiArtView.draw(emojiArtView.bounds)
            }
            document.thumbnail = thumbnail
        }
        dismiss(animated: true) {
            self.document.close(completionHandler: { [weak self] (success) in
                if success {
                    NotificationCenter.default.removeObserver(self?.documentObserver as Any)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropArea.addInteraction(UIDropInteraction(delegate: self))
    }
    
    var documentObserver: NSObjectProtocol?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        documentObserver = NotificationCenter.default.addObserver(forName: UIDocument.stateChangedNotification, object: document, queue: OperationQueue.main, using: { [weak self] (notification) in
            print("Document state change to \(String(describing: self?.document.documentState))")
        })
        
        document?.open(completionHandler: { [weak self] success in
            if success {
                self?.title = self?.document?.localizedName
                self?.emojiArt = self?.document?.emojiArt
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Close()
        
    }
    
    var backgroundImage: UIImage? {
        get{
            return emojiArtView.image
        }
        set{
            if scrollView != nil{
                scrollView.zoomScale = 1
                emojiArtView.image = newValue
                emojiArtView.sizeToFit()
                scrollView.contentSize = emojiArtView.bounds.size
                let size = emojiArtView.bounds.size
                if size.width != 0 && size.height != 0{
                    scrollView.setZoomScale(max(scrollView.bounds.width/size.width, scrollView.bounds.height/size.height), animated: true)
                }
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    var addingEmoji = false
    
    @IBAction func addEmoji(_ sender: UIButton) {
        addingEmoji = true
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    
}

// MARK: - UIDropInteractionDelegate

extension EmojiArtViewController: UIDropInteractionDelegate{
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { [weak self] (items) in
            if let images = items as? [UIImage]{
                self?.backgroundImage = images.first
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension EmojiArtViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        view?.setNeedsDisplay()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
}

extension EmojiArtViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    struct Identifier {
        static let emojiCell = "emojiCell"
        static let placeHolder = "placeholder"
        static let addButton = "addButton"
        static let textField = "textField"

    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }  else {return emojis.count}
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.emojiCell, for: indexPath)
            
            if let emojiCell = cell as? EmojiCollectionViewCell{
                emojiCell.emojiLabel.attributedText = NSAttributedString(string: emojis[indexPath.item], attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .body).withSize(64)])
            }
            return cell
        }
        else if addingEmoji {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.textField, for: indexPath)
            if let inputCell = cell as? TextFieldCollectionViewCell {
                inputCell.resignationHandler = { [weak self,weak inputCell] in
                    if self != nil, let text = inputCell?.textField.text {
                        self!.emojis = text.map{ String($0)} + self!.emojis
                    }
                    self?.addingEmoji = false
                    self?.collectionView.reloadData()
                }
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.addButton, for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 , let inputCell = cell as? TextFieldCollectionViewCell {
            inputCell.textField.becomeFirstResponder()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addingEmoji && indexPath.section == 0 {
            return CGSize(width: 320, height: 80)
        }
        else {
            return CGSize(width: 80, height: 80)
        }
    }
}
