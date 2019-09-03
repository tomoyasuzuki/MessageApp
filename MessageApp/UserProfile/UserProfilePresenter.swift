//
//  UserProfilePresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/01.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseFirestore
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
                // DEBUG: print(error!.localizedDescription)
            }
            self.view?.navigateToChats()
        }
    }
}
