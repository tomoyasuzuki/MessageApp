//
//  ChatSearchPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/06.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

protocol ChannelSearchPresenterProtocol {
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
        var temp: [String] = []
        
        self.channels = []
        
        FireBaseManager.shared.bindAllChannelSnapshot { (snapshot) in
            snapshot.documentChanges.forEach { [weak self] change in
                guard let self = self else { return }
                
                let documentID = change.document.documentID
    
                guard let name = change.document.data()["name"] as? String else { return }
                guard let members = change.document.data()["members"] as? [String] else { return }
                
                temp.append(name)
                temp.forEach { string in
                    if string.contains(text) {
                    let urlString = change
                            .document
                            .data()[Resources.strings.KeyImageURL] as! String
                        
                        let url = URL(string: urlString)
                        
                        let channel = Channel(id: documentID, name: name, image: UIImage(named: "userIcon")!, members: members)
                        self.channels.append(channel)
                        
//                        FireBaseManager.shared.getImageData(url) { data in
//                            guard let image = UIImage(data: data) else { return }
//
//                            let channel = Channel(id: documentID, name: name, image: UIImage(named: "userIcon")!, members: members)
//                            self.channels.append(channel)
//                        }
                    }
                }
                
                temp = []
            
                
                print("hit: \(self.channels.count)")
                
                if self.channels.isEmpty {
                    self.view?.changeTableViewStatus(isHidden: true)
                } else {
                    self.view?.changeTableViewStatus(isHidden: false)
                }
                
                self.view?.reloadData()
            }
        }
    }
}

