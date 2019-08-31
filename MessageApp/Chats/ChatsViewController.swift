//
//  UserInfoViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let user = Auth.auth().currentUser
    
    private var db = Firestore.firestore()
    private var ref: CollectionReference?
    
    private var channels: [Channel] = []
    private var messageListener: ListenerRegistration?
    
    // ユーザーが所属しているチャンネルを作成する
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = db.collection("channels")
        
        messageListener = ref?.whereField("members", arrayContains: user?.uid).addSnapshotListener({ (querySnapshot, error) in
            if querySnapshot == nil || error != nil {
                print("snapshot update error: \(error!.localizedDescription)")
                return
            }
            
            querySnapshot?.documentChanges.forEach({ change in
                self.handleDocumentChanged(change)
            })
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ChannelsTableViewCell.self, forCellReuseIdentifier: "ChannelTableViewCell")
    }
    
    private func handleDocumentChanged(_ change: DocumentChange) {
        guard let channel = Channel(change.document) else { return }
        
        switch change.type {
        case .added:
            insertNewChannel(channel)
        default:
            break
        }
    }
    
    private func insertNewChannel(_ channel: Channel) {
        channels.append(channel)
        tableView.reloadData()
    }
    
    @IBAction func createChannelButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Lets Create Channel!!", message: "please enter your Channel Name.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        let action = UIAlertAction(title: "Create", style: .default) { [weak self] action in
            guard let self = self else { return }
            guard let textFields = alert.textFields else { return }
            print("exits textfield")
            
            if let text = textFields[0].text {
                guard let user = self.user else { return }
                self.ref?.addDocument(data: ["name": text, "members": [user.uid]])
            }
        }
        
        print("will present")
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelsTableViewCell
        cell.configureDataSource(channel: channels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(ChatRoomViewController(id: channels[indexPath.row].id
            , name: channels[indexPath.row].name), animated: true)
    }
    
}
