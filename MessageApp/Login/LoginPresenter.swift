//
//  LoginPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore

protocol LoginPresenterProtocol {
    func signUp(email: String?,
                password: String?,
                repeatedPassword: String?) -> Void
    func login(email: String?,
               password: String?,
               repeatedPassword: String?) -> Void
}

class LoginPresenter: LoginPresenterProtocol {
    var view: LoginViewControllerProtocol? = nil
    
    private let ref = Firestore.firestore().collection("users")
    
    func signUp(email: String?, password: String?, repeatedPassword: String?) {
        if let email = email,let password = password, let repeatedPassword = repeatedPassword,
            !email.isEmpty, !password.isEmpty, !repeatedPassword.isEmpty {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
                guard let self = self else { return }
                
                if error != nil {
                    if !email.contains("@") || !email.contains(".") {
                        self.view?.showError(AuthError.invalidEmail)
                    } else if password.count < 6 {
                        self.view?.showError(AuthError.passwordIsLessThanSix)
                    } else if repeatedPassword != password {
                        self.view?.showError(AuthError.repeatedPasswordIsNotEqualToPassword)
                    } else {
                        self.view?.showError(AuthError.unexpected)
                    }
                    
                    return
                }
                
                self.createUser()
                self.view?.showSuccess()
                self.view?.navigateToUserProfile()
            }
        } else {
            self.view?.showError(AuthError.notFilledOut)
        }
    }
    
    func login(email: String?, password: String?, repeatedPassword: String?) {
        if let email = email,let password = password, let repeatedPassword = repeatedPassword,
            !email.isEmpty, !password.isEmpty, !repeatedPassword.isEmpty {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
                guard let self = self else { return }
                
                if error != nil {
                    self.view?.showError(AuthError.userIsNotExits)
                    return
                }
                
                self.view?.showSuccess()
                self.view?.navigateToChats()
            }
        } else {
            self.view?.showError(AuthError.notFilledOut)
        }
    }
    
    func createUser() {
        guard let  user = Auth.auth().currentUser else { return }
        ref.document(user.uid).setData(["name": user.displayName ?? "unknown",
                                        "id": user.uid,
                                        "imageURL": "",
                                        "belongs":[]])
    }
}
