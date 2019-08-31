//
//  ChatsTableViewCell.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/29.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsTableViewCell: UITableViewCell {
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    
    private var messageListener: ListenerRegistration?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(channel: Channel?) {
        guard let channel = channel else { return }
        
        chatNameLabel.text = channel.name
    }
    
    func handleDocumentChanged(_ change: DocumentChange) {
        
    }
}

