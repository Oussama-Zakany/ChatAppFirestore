//
//  ChatInputAccessoryView.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import UIKit

protocol ChatInputAccessoryViewDelegate {
    func didSend(for text: String)
}

class ChatInputAccessoryView: UIView {
    
    var delegate: ChatInputAccessoryViewDelegate?
    
    func clearChatTextField() {
        chatTextView.text = nil
        chatTextView.showPlaceholderLabel()
    }
    
    fileprivate let chatTextView: ChatInputTextView = {
        let tv = ChatInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()
    
    fileprivate let sendButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Send", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12), size: CGSize(width: 50, height: 50))
        
        addSubview(chatTextView)
        chatTextView.anchor(top: topAnchor, leading: leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: sendButton.leadingAnchor, padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0))
        
        setupLineSeparatorView()
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, size: CGSize(width: 0, height: 0.5))
    }
    
    @objc func handleSubmit() {
        guard let chatText = chatTextView.text else { return }
        delegate?.didSend(for: chatText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
