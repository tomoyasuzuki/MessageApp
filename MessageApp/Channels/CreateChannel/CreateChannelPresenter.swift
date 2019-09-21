//
//  CreateChannelPresenter.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/20.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit

final class CreateChannelPresenter {
    var view: CreateChannelViewControllerProtocol? = nil
    
    func save(text: String, members: [String], image: UIImage, complition: @escaping(Error?) -> ()) {
        FireBaseManager.shared.saveImageData(path: Resources.strings.KeyChannelImage, image: image) { (url) in
            FireBaseManager.shared.saveNewChannel(name: text, members: members,  imageURL: url) { (error) in
                complition(error)
            }
        }
    }
}
