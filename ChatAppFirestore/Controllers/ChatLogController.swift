//
//  ChatLogController.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController {
    
    private let cellId = "CellId"
    var messages = [Message]()
    
    var user: User? {
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    lazy var containerView: ChatInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let chatInputAccessoryView = ChatInputAccessoryView(frame: frame)
        chatInputAccessoryView.delegate = self
        return chatInputAccessoryView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    fileprivate func setupCollectionView(){
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.keyboardDismissMode = .interactive
    }
    
    func observeMessages(){
        let currentId = AuthService.shared.currentId()
        guard let userId = user?.id else { return }
        let converId = getConversationId(uid1: currentId, uid2: userId)
        
        reference(.Conversation).document(converId).collection("Messages").order(by: kSENTDATE).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach({ (change) in
                self.handleDocumentChange(change)
            })
        }
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        let document = change.document
        guard let message = Message(dictionary: document.data(), id: document.documentID) else { return }
        
        switch change.type {
        case .added:
            messages.append(message)
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            collectionView.reloadData()
            if collectionView.isAtBottom {
                collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
        default: break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.message = messages[indexPath.item]
        if let profileImageURL = self.user?.profileImageURL {
            cell.profileImageView.sd_setImage(with: URL(string: profileImageURL))
        }
        return cell
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = messages[indexPath.item].text
        let height = text.estimateFrameForText(fontSize: 16).height + 20
        return CGSize(width: view.frame.width, height: height)
    }
}

extension ChatLogController: ChatInputAccessoryViewDelegate {
    override var inputAccessoryView: UIView? {
        get { return containerView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func didSend(for text: String) {
        guard let toId = user?.id else { return }
        
        let dic: [String : Any] = [
            kTEXT: text,
            kTOID: toId,
            kFROMID: AuthService.shared.currentId(),
            kSENTDATE: Timestamp(date: Date())
        ]
        
        guard let message = Message(dictionary: dic) else { return }
        
        MessageService.shared.addMessage(message: message) { (result) in
            switch result {
            case .success(_):
                self.containerView.clearChatTextField()
            case .failure(let error):
                print(error)
            }
        }
    }
}
