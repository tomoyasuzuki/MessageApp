//
//  UpdateUserProfileError.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/01.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

enum UpdateUserProfileError: Error {
    case userNameIsInvalid
    case unexpected
    
    func errorText() -> String {
        switch self {
        case .userNameIsInvalid:
            return "username is invalid.Please use other name."
        case .unexpected:
            return "unexpected error."
        }
    }
}
