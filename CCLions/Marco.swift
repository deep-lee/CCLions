//
//  Marco.swift
//  CCLions
//
//  Created by 李冬 on 6/1/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

enum UserType: Int {
	case CCLionVip = 1
	case NonVip = 0
}

enum UserAuthenticationStatus: Int {
	case NotAuthentication = 0 // 未认证
	case InAuthentication = 1 // 认证中
	case FailAuthentication = 2 // 认证失败
	case SuccessAuthentication = 3 // 通过认证
}

let CELL_REUSE = "COMMON_CELL_REUSE"