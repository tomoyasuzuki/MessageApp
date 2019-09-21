//
//  UserInfoViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import SVProgressHUD
import SnapKit
import Firebase


protocol ChannelViewControllerProtocol {
    func showPopupView() -> Void
    func reloadData() -> Void
}

final class ChannelsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var presenter = ChannelPresenter()
    
    fileprivate lazy var createButton: UIButton = {
        return UIButton()
    }()
    
    fileprivate lazy var searchButton: UIButton = {
        return UIButton()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(createButton)
        view.addSubview(searchButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChannelsTableViewCell.self, forCellReuseIdentifier: "ChannelTableViewCell")
        
        configurePresenter()
        configureUIComponents()
        configureConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
   
    @objc func create() {
        self.showPopupView()
    }
    
    @objc func search() {
        self.performSegue(withIdentifier: "navigateToChatSearch", sender: nil)
    }
}

// MARK: Private Methods

extension ChannelsViewController {
    private func configurePresenter() {
        presenter.view = self
        presenter.updateChannels()
    }
    
    private func configureConstraints() {
        createButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(16)
            make.bottom.equalTo(view).offset(-16)
            make.width.height.equalTo(50)
        }
        
        searchButton.snp.makeConstraints { make in
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view).offset(-16)
            make.width.height.equalTo(50)
        }
    }
    
    private func configureUIComponents() {
        createButton.setImage(UIImage(named: "plus_3"), for: .normal)
        createButton.layer.cornerRadius = createButton.frame.height / 2
        createButton.clipsToBounds = true
        createButton.addTarget(self, action: #selector(create), for: .touchUpInside)
        
        searchButton.setImage(UIImage(named: "musimegane"), for: .normal)
        searchButton.layer.cornerRadius = searchButton.frame.height / 2
        searchButton.clipsToBounds = true
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
    }
}

// MARK: TableView Delegate

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
        let channel = presenter.channels[indexPath.row]
        navigationController?.pushViewController(ChatRoomViewController(id: channel.id, name: channel.name, image: channel.image, members: channel.members), animated: true)
    }
    
}

// MARK: Protocol Delegate

extension ChannelsViewController: ChannelViewControllerProtocol {
    func showPopupView() {
        // 画面遷移する
        self.performSegue(withIdentifier: "navigateToCreate", sender: nil)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}
