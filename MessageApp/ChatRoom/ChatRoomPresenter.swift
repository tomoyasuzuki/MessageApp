//
//  ChatRoomPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/02.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

protocol ChatRoomPresenterProtocol {
    func saveMessage(_ text: String) -> Void
    func saveMessage(_ url: URL) -> Void
    func saveAudioMessage(_ audioURL: URL) -> Void
    func updateMessages() -> Void
}

final class ChatRoomPresenter: ChatRoomPresenterProtocol {
    var view: ChatRoomViewControllerProtocol? = nil
    
    var channel: Channel? = nil
    var messages: [Message] = []
    
    let user = Auth.auth().currentUser
    var sender: Sender {
        let user = Auth.auth().currentUser
        return Sender(senderId: user!.uid, displayName: user!.displayName!)
    }
    
    private let db = Firestore.firestore()
    private var ref: CollectionReference {
        return db.collection(["channels", channel!.id, "threads"].joined(separator: "/"))
    }
    
    func saveMessage(_ text: String) {
        ref.addDocument(data: ["senderID": sender.senderId,
                               "senderName": sender.displayName,
                               "sentDate": Date.timeIntervalBetween1970AndReferenceDate,
                               "content": text,
                               "imageURL": ""]) { [weak self] error in
                                guard let self = self else { return }
                                if error != nil {
                                    //print("error: \(error!.localizedDescription)")
                                    return
                                }
                                self.view?.scrollToBottom()
        }
    }
    
    func saveMessage(_ url: URL) {
        ref.addDocument(data: ["senderID": sender.senderId,
                               "senderName": sender.displayName,
                               "sentDate": Date.timeIntervalBetween1970AndReferenceDate,
                               "content": "",
                               "imageURL": url.absoluteString]) { [weak self] error in
                                guard let self = self else { return }
                                if error != nil {
                                    //print("error: \(error!.localizedDescription)")
                                    return
                                }
                                self.view?.scrollToBottom()
        }
    }
    
    func saveAudioMessage(_ audioURL: URL) {
        print("audio called")
        ref.addDocument(data: ["senderID": sender.senderId,
                                    "senderName": sender.displayName,
                                    "sentDate": Date.timeIntervalBetween1970AndReferenceDate,
                                    "content": "",
                                    "imageURL": "",
                                    "audioURL": audioURL.description]) { [weak self] error in
                                        guard let self = self else { return }
                                        if error != nil {
                                            print("error: \(error!.localizedDescription)")
                                            return
                                        }
                                        self.view?.scrollToBottom()
        }
    }
    
    func updateMessages() {
        ref.addSnapshotListener { snapshot, error in
            if error != nil {
                //print("error: \(error!.localizedDescription)")
                return
            }
            
            snapshot?.documentChanges.forEach { [weak self] change in
                guard let self = self else { return }
                self.handleDocumentChange(change)
            }
        }
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .added:
            self.judgeMessageType(change: change) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .text:
                    let message = Message(text: change.document.data()["content"] as! String,
                                          sender: sender,
                                          messageId: "",
                                          sentDate: Date())
                    self.messages.append(message)
                case .photo:
                    guard let url = (change.document.data()["imageURL"] as! String).toURL() else { return }
                    getImage(url: url, complition: { image in
                        let message = Message(image: image,
                                              sender: self.sender,
                                              messageId: "",
                                              sentDate: Date())
                        
                        self.messages.append(message)
                    })
                    
                case .audio:
                    if let url = (change.document.data()["audioURL"] as! String).toURL() {
                        let message = Message(audioURL: url,
                                              sender: sender,
                                              messageId: "",
                                              sentDate: Date())
                        
                        self.messages.append(message)                        
                    } else {
                        print("message not appended")
                    }
            
                default:
                    break
                }
            }
            self.view?.reloadData()
        default:
            break
        }
    }
    
    func judgeMessageType(change: DocumentChange, complition: (MessageObjectType) -> ()) {
        let document = change.document
        
        if document.data()["content"] as? String != "" {
           complition(.text)
        } else if document.data()["imageURL"] as? String != "" {
           complition(.photo)
        } else if document.data()["audioURL"] as? String !=  "" {
            complition(.audio)
        }
    }
}

// MARK: Image Helpers

extension ChatRoomPresenter {
    func saveImage(_ image: UIImage, complition: @escaping (URL) -> ()) {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let ref = Storage.storage()
            .reference(withPath: "image")
            .child([UUID().uuidString, "\(Date().timeIntervalSince1970)"].joined(separator: "/"))
        
        ref.putData(data, metadata: metaData) { (metaData, error) in
            if error != nil {
                return
            }
            
            ref.downloadURL { (url, error) in
                guard let url = url else { return }
                if error != nil {
                    return
                }
                
                complition(url)
            }
        }
    }
    
    func getImage(url: URL, complition: @escaping(UIImage) -> ()) {
        let ref = Storage.storage().reference(forURL:url.absoluteString)
        
        ref.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            guard let data = data else { return }
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            complition(UIImage(data: data)!)
        }
    }
}

// MARK: Audio Helpers

extension ChatRoomPresenter {
    func saveAudioFile(_ localURL: URL) {
        let fileName = Date().description
        let audioRef = Storage.storage().reference().child("audio/\(fileName)")
        
        audioRef.putFile(from: localURL, metadata: nil) { metaData, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            audioRef.downloadURL { [weak self] url, error in
                guard let self = self else { return }
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let url = url else { return }
                self.saveAudioMessage(url)
            }
        }
    }
}

extension String {
    func toURL() -> URL? {
        return URL(string: self)
    }
}
