//
//  Extentions.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/12.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//
import Foundation
import MessageKit

// MAKR: String

extension String {
    func toURL() -> URL? {
        return URL(string: self)
    }
}

// MARK: Array

extension Array where Element: MessageType {
    mutating func sortByDate() -> Array<Element> {
        return self.sorted { $0.sentDate < $1.sentDate }
    }
}



