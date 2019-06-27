//
//  UserCell.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import UIKit
import SDWebImage

class UserCell: UITableViewCell {

    var user: User? {
        didSet{
            guard let user = user else { return }
            profileImageView.sd_setImage(with: URL(string: user.profileImageURL))
            txtLabel.text = user.name
            detailTxtLabel.text = user.email
        }
    }
    
    var message: Message? {
        didSet{
            guard let message = message else { return }
            
            detailTxtLabel.text = message.text
            timeLabel.text = message.sentDate.getElapsedInterval()
            
            if message.seen == false {
                seenView.isHidden = false
                timeLabel.textColor = UIColor.blueColor
            } else {
                seenView.isHidden = true
                timeLabel.textColor = nil
            }
            
            UserService.shared.fetchUser(userId: message.chatPartnerId) { (result) in
                switch result {
                case .success(let user):
                    self.profileImageView.sd_setImage(with: URL(string: user.profileImageURL), placeholderImage: UIImage(named: kDEFAULTIMG))
                    self.txtLabel.text = user.name
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let txtLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let detailTxtLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.right
        return label
    }()
    
    let seenView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blueColor
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(txtLabel)
        addSubview(detailTxtLabel)
        addSubview(timeLabel)
        addSubview(seenView)
        
        profileImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0), size: CGSize(width: 50, height: 50))
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        txtLabel.anchor(top: profileImageView.topAnchor, leading: profileImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 8, bottom: 0, right: 8))
        detailTxtLabel.anchor(top: txtLabel.bottomAnchor, leading: profileImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 8, bottom: 0, right: 8))
        timeLabel.anchor(top: profileImageView.topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 16), size: CGSize(width: 100, height: 0))
        seenView.anchor(top: timeLabel.bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 32), size: CGSize(width: 16, height: 16))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
