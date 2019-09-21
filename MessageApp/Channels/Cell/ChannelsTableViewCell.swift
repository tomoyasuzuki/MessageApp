//
//  ChannelsTableViewCell.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/31.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class ChannelsTableViewCell: UITableViewCell {
    
    fileprivate lazy var channelImageView: UIImageView = {
        return UIImageView()
    }()
    
    fileprivate lazy var channelNameLabel: UILabel = {
        return UILabel()
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(channelImageView)
        contentView.addSubview(channelNameLabel)
        
        configueUIComponents()
        configureConstraints()
    }
}

extension ChannelsTableViewCell {
    func configueUIComponents() {
        channelImageView.layer.cornerRadius = channelImageView.frame.height / 2
        channelImageView.clipsToBounds = true
    }
    
    func configureConstraints() {
        channelImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(16)
            make.width.height.equalTo(50)
        }
        
        channelNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(channelImageView)
            make.left.equalTo(channelImageView.snp.right).offset(16)
        }
    }
    
    func configureDataSource(channel: Channel) {
        channelImageView.image = channel.image
        channelNameLabel.text = channel.name
    }
}
