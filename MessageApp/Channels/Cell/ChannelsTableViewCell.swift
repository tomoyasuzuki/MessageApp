//
//  ChannelsTableViewCell.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/31.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import SnapKit

class ChannelsTableViewCell: UITableViewCell {
    
    fileprivate lazy var channelImageView: UIImageView = {
        return UIImageView()
    }()
    
    fileprivate lazy var channelNameLabel: UILabel = {
        return UILabel()
    }()
    
    fileprivate lazy var latestMessageLabel: UILabel = {
        return UILabel()
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(channelImageView)
        contentView.addSubview(channelNameLabel)
        contentView.addSubview(latestMessageLabel)
        
        configureConstraints()
    }
}

extension ChannelsTableViewCell {
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
        
        latestMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(channelNameLabel.snp.bottom).offset(8)
            make.left.equalTo(channelNameLabel)
        }
    }
    
    func configureDataSource(channel: Channel) {
        channelImageView.image = UIImage(named: "userIcon")
        channelNameLabel.text = channel.name
        // TODO: 最新のメッセージを取得できるようにする
        // Channelオブジェクト自体が初期化時にoptionalのlatestMessageプロパティを持っている状態にする。
        latestMessageLabel.text = "to be continue....."
    }
}

