//
//  UserProfilePresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/01.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

protocol UserProfilePresenterProtocol {
    func setUserDisplayName(name: String) -> Void
}

final class UserProfilePresenter: UserProfilePresenterProtocol {
    var view: UserProfileViewControllerProtocol? = nil
    
    func setUserDisplayName(name: String) {
        guard let user = Auth.auth().currentUser else { return }
        if name.contains("@") || name.contains(".") {
            self.view?.showError(UpdateUserProfileError.userNameIsInvalid)
            return
        }
        
        let request = user.createProfileChangeRequest()
        request.displayName = name
        
        request.commitChanges { [weak self] error in
            guard let self = self else { return }
            
            if error != nil {
                self.view?.showError(UpdateUserProfileError.unexpected)
            }
            self.view?.navigateToChats()
        }
    }
    
    
    func saveUserProfileImage(_ image: UIImage, Successd: @escaping(Bool) -> ()) {
        // 保存先を指定
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let localPath = documentDirectoryURL.appendingPathComponent("profileImage.jpeg")
        
        // 画像を圧縮してドキュメントに保存する
        guard let jpegData = image.jpegData(compressionQuality: 1.0) else { return }
        
        do  {
            try jpegData.write(to: localPath)
            // 保存先のパスをUserdefaultsに保存する
            UserDefaults.standard.set(localPath, forKey: "profileImage")
            Successd(true)
        } catch {
            print("fail compress image to data.")
            Successd(false)
        }
    }
    
    func saveImageDataToStorage(_ data: Data) {
        FireBaseManager.shared.saveData(path: Resources.strings.KeyProfileImage, data: data) { (url) in
            if let url = url {
                FireBaseManager.shared.changeUserInfo(imageURL: url)
            } else {
                return
            }
        }
    }
}
