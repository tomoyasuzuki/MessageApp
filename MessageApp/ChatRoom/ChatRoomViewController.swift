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
        
        configurePresenter()
        configureMessageUI()
        
        audioController = AudioController(messageCollectionView: messagesCollectionView)
        
        
        let longpressRecgnizer = UILongPressGestureRecognizer(target: self, action: #selector(startRecording))
        longpressRecgnizer.delegate = self
        view.addGestureRecognizer(longpressRecgnizer)
        
        navigationItem.title = presenter.channel?.name
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
        guard let localURL = audioController?.createLocalURL() else { return }
        
        if sender.state == .began {
            audioController?.startRecordingAudio(url: localURL)
        } else if sender.state == .ended {
            audioController?.stopRecordingAudio()
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

