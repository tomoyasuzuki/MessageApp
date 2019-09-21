//
//  ChannelSearchTableViewCell.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/15.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class ChannelSearchTableViewCell: UITableViewCell {
    
    private var channel: Channel?
    
    fileprivate lazy var channelImageView: UIImageView = {
        return UIImageView()
    }()
    
    fileprivate lazy var channelNameLabel: UILabel = {
        return UILabel()
    }()
    
    fileprivate lazy var channelMembersCountLabel: UILabel = {
        return UILabel()
    }()
    
    fileprivate lazy var joinButton: UIButton = {
        return UIButton()
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(channelImageView)
        contentView.addSubview(channelNameLabel)
        contentView.addSubview(channelMembersCountLabel)
        contentView.addSubview(joinButton)
        
        configureUIComponents()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ChannelSearchTableViewCell {
    func configureDataSource(_ channel: Channel) {
        self.channel = channel
        
        channelImageView.image = channel.image
        channelNameLabel.text = channel.name
        channelMembersCountLabel.text = "メンバー数：\(channel.members.count.description)"
    }
    
    private func configureUIComponents() {
        channelImageView.contentMode = .scaleAspectFit
        channelImageView.clipsToBounds = true
        channelImageView.layer.cornerRadius = channelImageView.frame.height/2
        
        joinButton.backgroundColor = UIColor.green
        joinButton.layer.cornerRadius = 4.0
        joinButton.clipsToBounds = true
        joinButton.alpha = 0.7
        joinButton.setTitle("Join", for: .normal)
        joinButton.addTarget(self, action: #selector(joinChannel), for: .touchUpInside)
    }
    
    @objc func joinChannel() {
        guard let user = Auth.auth().currentUser else { return }
        let ref = Firestore.firestore().collection(Resources.strings.KeyChannels)
        // documentIDを指定してチャンネルに参加できるようにする
        ref.document("documentID").updateData([Resources.strings.KeyMembers: user.uid]) { (error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    private func configureConstraints() {
        channelImageView.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(16)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(50)
        }
        
        channelNameLabel.snp.makeConstraints { make in
            make.left.equalTo(channelImageView.snp.right).offset(16)
            make.centerY.equalTo(channelImageView)
        }
        
        channelMembersCountLabel.snp.makeConstraints { make in
            make.right.equalTo(joinButton.snp.left).offset(-16)
            make.centerY.equalTo(joinButton)
        }
        
        joinButton.snp.makeConstraints { make in
            make.right.equalTo(contentView).offset(-16)
            make.centerY.equalTo(contentView)
            make.width.equalTo(70)
            make.height.equalTo(40)
        }
    }
}
