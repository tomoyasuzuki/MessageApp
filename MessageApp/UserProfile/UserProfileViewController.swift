//
//  UserProfileViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/29.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class UserProfileViewController: UIViewController {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var imageEditButton: UIButton!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!

    let user = Auth.auth().currentUser
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func nextButtonTapped(_ sender: Any) {
        if let name = nameTextField.text, !name.isEmpty {
            let request = user?.createProfileChangeRequest()
            request?.displayName = name
            
            request?.commitChanges { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    SVProgressHUD.showError(withStatus: "Error: Please retry.")
                    print(error.localizedDescription)
                }
                self.performSegue(withIdentifier: "navigateToChatsFromSignUp", sender: nil)
            }
        } else {
            return
        }
    }
}
