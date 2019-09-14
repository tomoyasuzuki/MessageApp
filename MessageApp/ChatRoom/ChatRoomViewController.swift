//
//  ChatRoomViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Photos
import FirebaseStorage
import FirebaseFirestore

protocol ChatRoomViewControllerProtocol {
    func reloadData() -> Void
    func scrollToBottom() -> Void
}

class ChatRoomViewController: MessagesViewController {
    
    private let presenter = ChatRoomPresenter()
    
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
        }()
    
    var audioRecorder: AVAudioRecorder!
    var isRecording: Bool = false
    var isPlaying: Bool = false
    
    var audioController: AudioController?
    
    
    var id: String!
    var name: String!
    
    init(id: String, name: String) {
        super.init(nibName: nil, bundle: nil)
        self.id = id
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = presenter.channel?.name
        
        configurePresenter()
        configureMessageUI()
        configureAutoCompleteManager()
        configureRecognizer()
        
        audioController = AudioController(messageCollectionView: messagesCollectionView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioController?.stopAudio()
    }
    
    @objc func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
}


extension ChatRoomViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        presenter.saveMessage(text)
        inputBar.inputTextView.text = ""
    }
}

extension ChatRoomViewController {
    private func configureRecognizer() {
        let longpressRecgnizer = UILongPressGestureRecognizer(target: self, action: #selector(startRecording))
        longpressRecgnizer.delegate = self
        view.addGestureRecognizer(longpressRecgnizer)
    }
    
    private func configureAutoCompleteManager() {
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.gray, .backgroundColor: UIColor.green])
        autocompleteManager.maxSpaceCountDuringCompletion = 1
    }
    
    private func configurePresenter() {
        presenter.view = self
        presenter.channel = Channel(id: id, name: name)
        presenter.updateMessages()
    }
    
    private func configureMessageUI() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.green
        messageInputBar.inputTextView.placeholder = "Message"
        
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .black
        cameraItem.image = UIImage(named: "imageicon_image")
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        let audioItem = InputBarButtonItem(type: .system)
        audioItem.tintColor = .black
        audioItem.image = UIImage(named: "audioIcon")
        audioItem.setSize(CGSize(width: 50, height: 25), animated: false)
        
        
        cameraItem.addTarget(self,action: #selector(cameraButtonPressed),for: .primaryActionTriggered)
        audioItem.addTarget(self, action: #selector(startRecording), for: .primaryActionTriggered)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 110, animated: false)
        messageInputBar.setStackViewItems([cameraItem, audioItem], forStack: .left, animated: false)
        
        messageInputBar.inputPlugins = [autocompleteManager]
    }
}

extension ChatRoomViewController: ChatRoomViewControllerProtocol {
    func reloadData() {
        messagesCollectionView.reloadData()
    }
    
    func scrollToBottom() {
        messagesCollectionView.scrollToBottom()
    }
}


extension ChatRoomViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return presenter.sender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return presenter.messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return presenter.messages[indexPath.section]
    }
}

extension ChatRoomViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .green : .white
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .black
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController?.configureAudioCell(cell, message: message)
    }

}

// Photos method

extension ChatRoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let asset = info[.phAsset] as? PHAsset {
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: 100, height: 100),
                                                  contentMode: .aspectFit,
                                                  options: nil) { [weak self] image, info in
                                                    guard let self = self else { return }
                                                    guard let image = image else { return }
                                                    
                                                    self.presenter.saveImage(image) { [weak self] url in
                                                        guard let self = self else { return }
                                                        self.presenter.saveMessage(url)
                                                    }
            }
            
        } else if let image = info[.originalImage] as? UIImage {
            self.presenter.saveImage(image) { [weak self] url in
                guard let self = self else { return }
                self.presenter.saveMessage(url)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// UITapGesture

extension ChatRoomViewController: UIGestureRecognizerDelegate, AVAudioRecorderDelegate {
    @objc func startRecording(_ sender: UILongPressGestureRecognizer) {
        print("start recording")
        guard let localURL = audioController?.createLocalURL() else { return }
        
        if sender.state == .began {
            audioController?.startRecordingAudio(url: localURL)
            print("began")
        } else if sender.state == .ended {
            audioController?.stopRecordingAudio()
            print("finish recording")
            // Firebase Storage にローカルの音声ファイルを保存する
            self.presenter.saveAudioFile(localURL)
        }
    }
}

extension ChatRoomViewController: MessageCellDelegate, AVAudioPlayerDelegate {
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = presenter.messages[indexPath.row]
        
        if audioController?.state == .playing {
            audioController?.pauseAudio(message: message, cell: cell)
        } else if audioController?.state == .pause {
            audioController?.resumeAudio(message: message, cell: cell)
        } else if audioController?.state == .stopped {
            audioController?.playAudio(message: message, cell: cell)
        } else {
            audioController?.stopAudio()
        }
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        print("did startd audio")
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("did stop audio")
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("did pause audio")
    }
}


extension ChatRoomViewController: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        print("should become visible")
        setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        
        if prefix == "@" {
            print("prefix is @")
            return presenter.messages.map { return AutocompleteCompletion(text: $0.sender.displayName, context: ["id": $0.sender.senderId])}
        } else {
            return []
        }
    }
    
    
    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else { fatalError("autocomplete cell is nil") }
        
        let users = presenter.messages.map{ $0.sender }
        let id = session.completion?.context?["id"] as? String
        let user = users.filter { return $0.senderId == id }.first
        if let sender = user {
//            cell.imageView?.image = UIImage(contentsOfFile: fileURL.path)
        }
        
        cell.imageViewEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        cell.imageView?.layer.cornerRadius = 14
        cell.imageView?.layer.borderColor = UIColor.green.cgColor
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15)
        return cell
    }
    
    func setAutocompleteManager(active: Bool) {
        let topStackView = messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
            print("active")
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
            print("not active")
        }
        messageInputBar.invalidateIntrinsicContentSize()
    }
}
    


