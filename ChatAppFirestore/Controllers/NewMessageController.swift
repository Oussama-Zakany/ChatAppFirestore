//
//  NewMessageController.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    private let cellId = "CellId"
    var users = [User]()
    var messageController: MessagesController?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigationBar()
        fetchUsers()
    }

    fileprivate func setupNavigationBar() {
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    fileprivate func setupTableView() {
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    func fetchUsers(){
        reference(.Users).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach({ (change) in
                self.handleDocumentChange(change)
            })
        }
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        let document = change.document
        let user = User(_dictionary: document.data(), _id: document.documentID)
        switch change.type {
        case .added:
            guard user.id != AuthService.shared.currentId() else { return }
            users.append(user)
            let indexPath = IndexPath(row: users.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .none)
        default: break
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        dismiss(animated: true) {
            self.messageController?.showChatController(user: user)
        }
    }
    
}
