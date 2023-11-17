//
//  VoteCreateRequestModel.swift
//  TwoHoSun
//
//  Created by 김민 on 10/21/23.
//

import SwiftUI

enum VoteType {
    case agree, disagree

    var isAgree: Bool {
        switch self {
        case .agree:
            return true
        case .disagree:
            return false
        }
    }

    var title: String {
        switch self {
        case .agree:
            return "추천"
        case .disagree:
            return "비추천"
        }
    }

    var subtitle: String {
        switch self {
        case .agree:
            return "사는"
        case .disagree:
            return "사지 않는"
        }
    }
}

//enum VoteType: String, Codable {
//    case agree = "AGREE"
//    case disagree = "DISAGREE"
//
//    var title: String {
//        switch self {
//        case .agree:
//            return "산다"
//        case .disagree:
//            return "안산다"
//        }
//    }
//
//    var color: Color {
//        switch self {
//        case .agree:
//            return Color("agreeColor")
//        case .disagree:
//            return Color("disagreeColor")
//        }
//    }
//
//    var subtitle: String {
//        switch self {
//        case .agree:
//            return "사는"
//        case .disagree:
//            return "사지 않는"
//        }
//    }
//}
