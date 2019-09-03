//
//  LoginPresenterProtocol+AuthError.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/31.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

enum AuthError: Error {
    case notFilledOut
    case invalidEmail
    case passwordIsLessThanSix
    case repeatedPasswordIsNotEqualToPassword
    case userIsNotExits
    case unexpected
    
    func errorText() -> String {
        switch self {
        case .notFilledOut:
            return "Please fill out all."
        case .invalidEmail:
            return "email is invalid."
        case .passwordIsLessThanSix:
            return "password must be more than six characters."
        case .repeatedPasswordIsNotEqualToPassword:
            return "repeated password is not equal to password."
        case .userIsNotExits:
            return "user is not exits."
        case .unexpected:
            return "unexpected error."
        }
    }
}
