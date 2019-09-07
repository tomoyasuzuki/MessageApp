//
//  ChatSearchPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/06.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//
import FirebaseFirestore
import FirebaseAuth

protocol ChannelSearchPresenterProtocol {
    func judgeTableViewStatus() -> Bool
    func fetchChannels(_ text: String) -> Void
}

final class ChannelSearchPresenter {
    var view: ChatSearchViewControllerProtocol? = nil
    let user = Auth.auth().currentUser
    
    var contains: [String] = []
    var channels: [Channel] = []
}

extension ChannelSearchPresenter: ChannelSearchPresenterProtocol {
    func fetchChannels(_ text: String) {
        let ref = Firestore.firestore().collection("channels")
        var temp: [String] = []
        
        self.channels = []
        
        ref.addSnapshotListener { snapshot, error in
            if error != nil {
                return
            }
            
            snapshot?.documentChanges.forEach { [weak self] change in
                guard let self = self else { return }
                
                let document = change.document
                
                guard let name = document.data()["name"] as? String else { return }
                
                temp.append(name)
                temp.forEach { string in
                    if string.contains(text) {
                        let channel = Channel(id: document.documentID, name: name)
                        self.channels.append(channel)
                    } else {
                        return
                    }
                }
                temp = []
    
                self.view?.reloadData()
                self.view?.changeTableViewStatus(isHidden: self.judgeTableViewStatus())
            }
        }
    }
    
    func judgeTableViewStatus() -> Bool {
        if channels.isEmpty {
            return true
        } else {
            return false
        }
    }
}

