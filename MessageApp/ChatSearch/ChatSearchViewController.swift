//
//  ChatSearchViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/06.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import SVProgressHUD
import SnapKit

protocol ChatSearchViewControllerProtocol {
    func changeTableViewStatus(isHidden: Bool) -> Void
    func reloadData() -> Void
}

final class ChatSearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let presenter = ChannelSearchPresenter()
    
    private var noChannelLabel: UILabel = {
       return UILabel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ChatSearch"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChannelSearchTableViewCell.self, forCellReuseIdentifier: "ChannelSearchCell")
        searchBar.delegate = self
        
        presenter.view = self
        configureUIComponents()
    }
    
    private func configureUIComponents() {
        view.addSubview(noChannelLabel)
        noChannelLabel.text = "チャンネルがありません"
        noChannelLabel.textColor = UIColor.gray
        noChannelLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        noChannelLabel.isHidden = false
        tableView.isHidden = true
        
        noChannelLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
}

extension ChatSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelSearchCell", for: indexPath) as! ChannelSearchTableViewCell
        cell.configureDataSource(presenter.channels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension ChatSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        SVProgressHUD.show()
        presenter.fetchChannels(searchText)
        SVProgressHUD.dismiss()
    }
}


extension ChatSearchViewController: ChatSearchViewControllerProtocol {
    func changeTableViewStatus(isHidden: Bool) {
        tableView.isHidden = isHidden
        noChannelLabel.isHidden = !isHidden
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}
