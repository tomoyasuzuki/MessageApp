//
//  ChannelsPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/01.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

protocol ChannelPresenterProtocol {
    func updateChannels() -> Void
}

final class ChannelPresenter {
    var view: ChannelViewControllerProtocol? = nil
    var channels: [Channel] = []
    
    private let user = Auth.auth().currentUser
    
    func insertNewChannel(_ channel: Channel) {
        channels.append(channel)
        self.view?.reloadData()
    }
}

extension ChannelPresenter {
    private func handleDocumentChanged(_ change: DocumentChange) {
        let document = change.document
        
        guard let name = document.data()[Resources.strings.KeyName] as? String else { return }
        guard let members = document.data()[Resources.strings.KeyMembers] as? [String] else { return }
        guard let url = document.data()[Resources.strings.KeyImageURL] as? String else { return }
        
        guard let imageURL = URL(string: url) else { return }
        
        FireBaseManager.shared.getImageData(imageURL) { (data) in
            guard let image = UIImage(data: data) else { return }
            
            let channel = Channel(id: document.documentID, name: name, image: image, members: members)
            
            switch change.type {
            case .added:
                self.insertNewChannel(channel)
            default:
                break
            }
        }
    }
}

extension ChannelPresenter: ChannelPresenterProtocol {
    func updateChannels() {
        guard let user = user else { return }
        
        FireBaseManager.shared.bindSnapshot(userId: user.uid) { (snapshot) in
            snapshot.documentChanges.forEach { (documentchange) in
                self.handleDocumentChanged(documentchange)
            }
        }
    }
}
