//
//  NSNotification+.swift
//  TwoHoSun
//
//  Created by 김민 on 11/23/23.
//

import Foundation

extension NSNotification {
    static let reviewCreated = Notification.Name.init("ReviewCreated")
    static let voteCreated = Notification.Name.init("VoteCreated")
    static let userBlockStateUpdated = Notification.Name.init("UserBlockStateUpdated")
}

