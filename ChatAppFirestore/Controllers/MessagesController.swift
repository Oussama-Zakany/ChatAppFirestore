//
//  ViewController.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    private let cellId = "CellId"
    var messages = [Message]()
    var messagesDic = [String : Message]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTableView()
        observeUserMessages()
    }
    
    fileprivate func setupNavigationBar() {
        let user = AuthService.shared.currentUser()
        navigationItem.title = user?.name
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(handleNewMessage))
    }
    
    fileprivate func setupTableView() {
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    func showChatController(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout() {
        AuthService.shared.logOutCurrentUser { (result) in
            switch result {
            case .success(_):
                let navigationController = UINavigationController(rootViewController: LoginController())
                UIApplication.setRootView(navigationController)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        present(navigationController, animated: true)
    }
    
    func observeUserMessages() {
        let userId = AuthService.shared.currentId()
        reference(.LastestMessages).document(userId).collection("Users").order(by: kSENTDATE).addSnapshotListener { (snapshot, error) in
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
            messages.insert(message, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .none)
        case .modified:
            guard let index = messages.firstIndex(where: {$0.chatPartnerId == message.chatPartnerId}) else { return }
            messages[index] = message
            updateCell(message: message, index: index)
            
        default: break
        }
    }
    
    func updateCell(message: Message, index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? UserCell
        cell?.timeLabel.text = message.sentDate.string(format:" hh:mm a")
        cell?.detailTxtLabel.text = message.text
        
        if navigationController?.topViewController is ChatLogController {
            cell?.seenView.isHidden = true
            cell?.timeLabel.textColor = nil
            MessageService.shared.updateSeen(message: message)
            messages[index].seen = true
        } else {
            cell?.seenView.isHidden = false
            cell?.timeLabel.textColor = UIColor.blueColor
        }
        
        messages.bringToFront(item: message)
        let topIndex = IndexPath(row: 0, section: 0)
        tableView.moveRow(at: indexPath, to: topIndex)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        UserService.shared.fetchUser(userId: message.chatPartnerId) { (result) in
            switch result {
            case .success(let user):
                MessageService.shared.updateSeen(message: message)
                self.messages[indexPath.row].seen = true
                self.showChatController(user: user)
            case .failure(let error):
                print(error)
            }
        }
    }
}
