//
//  ViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatedPasswordTextField: UITextField!
    
    private var db = Firestore.firestore()
    private var ref: CollectionReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = db.collection("users")
    }
    
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text, let repeatedPassword = repeatedPasswordTextField.text {
            if !email.isEmpty, !password.isEmpty, !repeatedPassword.isEmpty, password == repeatedPassword {
                Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: "SingUp Error: \(error!.localizedDescription)")
                        SVProgressHUD.dismiss(withDelay: 1.0)
                        return
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "Success!")
                        SVProgressHUD.dismiss(withDelay: 1.0)
                    }
                    self.performSegue(withIdentifier: "navigateToUserProfile", sender: nil)
                }
            }
        }
    }
    
    @IBAction func singInButtonTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text, let repeatedPassword = repeatedPasswordTextField.text {
            if !email.isEmpty, !password.isEmpty, !repeatedPassword.isEmpty, password == repeatedPassword {
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
                    guard let self = self else { return }
                    
                    if error != nil {
                        SVProgressHUD.showError(withStatus: "SignIn Error")
                        return
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "Success!")
                        self.createUserDocument()
                        self.performSegue(withIdentifier: "navigateToChatsFromLogin", sender: nil)
                    }
                }
            } else {
                SVProgressHUD.showError(withStatus: "Please FillOut Form.")
            }
        } else {
            SVProgressHUD.showError(withStatus: "Please FillOut Form.")
        }
    }
}

extension LoginViewController {
    func createUserDocument(){
        guard let  user = Auth.auth().currentUser else { return }
        ref?.document(user.uid).setData(["name": user.displayName, "belongs":[]])
    }
}

