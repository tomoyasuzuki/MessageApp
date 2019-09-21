//
//  FirebaseManager.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/19.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import Foundation
import Firebase
import MessageKit

final class FireBaseManager {
    static let shared = FireBaseManager()

    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    
    private let user = Auth.auth().currentUser
    
    private let maxDataSize: Int64 = 1 * 1024 * 1024
    
    // MARK: Snapshot Bind
    
    public func bindSnapshot(channelId: String, complition: @escaping(QuerySnapshot) -> ()) {
        let ref = firestore.collection([
            Resources.strings.KeyChannels,
            channelId,
            Resources.strings.KeyThreads].joined(separator: "/"))
        
        ref.addSnapshotListener { (snapshot, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else { return }
            complition(snapshot)
        }
    }
    
    public func bindSnapshot(userId: String, complition: @escaping(QuerySnapshot) -> ()) {
        let ref = firestore.collection(Resources.strings.KeyChannels)
        
        ref.whereField(Resources.strings.KeyMembers, arrayContains: userId)
            .addSnapshotListener { (snapshot, error) in
                guard error == nil else  {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                complition(snapshot)
        }
    }
    
    // MARK: Save New Channel
    
    public func saveNewChannel(name: String, members: [String], imageURL: URL, complition: @escaping(Error?) -> ()) {
        let ref = firestore.collection(Resources.strings.KeyChannels)
        
        ref.addDocument(data: [Resources.strings.KeyName: name,
                               Resources.strings.KeyMembers: members,
                               Resources.strings.KeyImageURL: imageURL.absoluteString]) { (error) in
                                
                                complition(error)
                                
        }
    }
    
    public func bindAllChannelSnapshot(complition: @escaping(QuerySnapshot) -> ()) {
        let ref = firestore.collection(Resources.strings.KeyChannels)
        
        ref.addSnapshotListener { (snapshot, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            complition(snapshot)
        }
    }
    
    // MARK: Save Message
    
    public func saveMessage(channelId: String, storedMessage: StoredMessageObject, complition: @escaping(Error?) -> ()) {
        
        if storedMessage.content == nil && storedMessage.imageURL == nil && storedMessage.audioURL == nil {
            return
        }
        
        let ref = firestore
            .collection([Resources.strings.KeyChannels, channelId, Resources.strings.KeyThreads].joined(separator: "/"))
        
        
        ref.addDocument(data: [Resources.strings.KeySenderId : storedMessage.senderId,
                               Resources.strings.KeySenderName: storedMessage.senderName,
                               Resources.strings.KeySentDate : Date(),
                               Resources.strings.KeyContent : storedMessage.content ?? "",
                               Resources.strings.KeyImageURL: storedMessage.imageURL ?? "",
                               Resources.strings.KeyAudioURL: storedMessage.audioURL ?? ""]) { (error) in
                                guard error == nil else {
                                    print(error!.localizedDescription)
                                    complition(error)
                                    return
                                }
                                
                                complition(error)
        }
        
    }
    
    // MARK: SaveData
    
    public func saveData(path: String, data: Data?, complition: @escaping(URL?) -> ()) {
        guard
            let user = user,
            let data = data else { return }
        
        let ref = storage
            .reference(withPath: path)
            .child(user.uid)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        ref.putData(data, metadata: metaData) { (_, error) in
            guard error == nil else { return }
            
            ref.downloadURL { (url, error) in
                guard error == nil else { return }
                
                complition(url)
                
            }
        }
    }
    
    // MARK: Save ImageData
    
    public func saveImageData(path: String, image: UIImage, complition: @escaping(URL) -> ()) {
        let ref = storage
            .reference(withPath: path)
            .child([UUID().uuidString, "\(Date().timeIntervalSince1970)"].joined(separator: "/"))
        
        guard let data = image.jpegData(compressionQuality: 0.4) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        ref.putData(data, metadata: metaData) { (_, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            ref.downloadURL { (url, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let url = url else { return }
                
                complition(url)
            }
        }
    }
    
    // MARK: Get ImageData
    
    public func getImageData(_ url: URL?, complition: @escaping(Data) -> ()) {
        guard let url = url else { return }
        let ref = storage.reference(forURL: url.absoluteString)
        
        ref.getData(maxSize: maxDataSize) { (data, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            complition(data)
            
        }
    }
    
    // MARK: Save AudioData
    
    public func saveAudioData(_ url: URL?, complition: @escaping(URL) -> ()) {
        guard let url = url else {
            print("local url is nil")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("cannot cast data")
            return
        }
        
        let fileName = UUID().uuidString
        let ref = storage.reference(withPath: Resources.strings.KeyAudioFile)
        
        let metaData = StorageMetadata()
        metaData.contentType = "aduio/m4a"
        
        ref.child(fileName).putData(data, metadata: metaData) { (_, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            ref.child(fileName).downloadURL { url, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let url = url else { return }
                
                complition(url)
            }
        }
    }
    
    // MARK: Get AudioData
    
    public func getAudioData(_ url: URL?, complition: @escaping(Data) -> ()) {
        guard let url = url else {
            print("audio downloadURL is invalid")
            return
        }
        
        let ref = storage.reference(forURL: url.absoluteString)
        
        ref.getData(maxSize: maxDataSize) { (data, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            complition(data)
        }
    }
    
    // MARK: Get User
    
    public func getUser(id: String, complition: @escaping(QuerySnapshot?) -> ()) {
        let ref = firestore.collection(Resources.strings.KeyUsers)
        
        ref.whereField("id", isEqualTo: id)
                      .getDocuments { (snapshot, error) in
                        complition(snapshot)
        }
    }
    
    // MARK: Chnageu User Properties
    
    public func changeUserInfo(name: String? = nil, imageURL: URL? = nil, willJoinChannelId: String? = nil) {
        guard let user = user else { return }
        
        getUser(id: user.uid) { (snapshot) in
            snapshot?.documentChanges.forEach { documentchange in
                if documentchange.document.data()["id"] as? String == user.uid {
                    var data = documentchange.document.data()
                    
                    if let name = name {
                        data[Resources.strings.KeyName] = name
                    }
                    
                    if let imageURL = imageURL {
                        data[Resources.strings.KeyImageURL] = imageURL.absoluteString
                    }
                    
                    if let willJoinChannelId = willJoinChannelId {
                        var belongs = data[Resources.strings.KeyBelongs] as? [String]
                        
                        belongs?.append(willJoinChannelId)
                        
                        data[Resources.strings.KeyBelongs] = belongs
                    }
                }
            }
        }
    }
}
