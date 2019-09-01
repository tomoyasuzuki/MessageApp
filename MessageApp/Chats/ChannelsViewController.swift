//
//  UserInfoViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import Firebase

class ChannelsViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private lazy var presenter = ChannelPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.chatchChatsSnapshot()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChannelsTableViewCell.self, forCellReuseIdentifier: "ChannelTableViewCell")
    }
    
   
    @IBAction func createChannelButtonTapped(_ sender: Any) {
        self.showAlert()
    }
}

extension ChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelsTableViewCell
        cell.configureDataSource(channel: presenter.channels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(ChatRoomViewController(id: presenter.channels[indexPath.row].id
            , name: presenter.channels[indexPath.row].name), animated: true)
    }
    
}


extension ChannelsViewController {
    func showAlert() {
        let alert = UIAlertController(title: "Lets Create Channel!!", message: "please enter your Channel Name.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        let action = UIAlertAction(title: "Create", style: .default) { [weak self] action in
            guard let self = self else { return }
            guard let textFields = alert.textFields else { return }
            
            if let text = textFields[0].text {
                self.presenter.addUserDocument(channelName: text)
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
}
