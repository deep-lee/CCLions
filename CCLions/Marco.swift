//
//  Marco.swift
//  CCLions
//
//  Created by 李冬 on 6/1/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

// 用户类型
enum UserType: Int {
case CCLionVip               = 1
case NonVip                  = 0
}

// 用户认证状态
enum UserAuthenticationStatus: Int {
case NotAuthentication       = 0// 未认证
case InAuthentication        = 1// 认证中
case FailAuthentication      = 2// 认证失败
case SuccessAuthentication   = 3// 通过认证
}

// 提款状态
enum WithdrawStatus: Int {
case ApplyIn                 = 1// 申请中
case ApplyFail               = 2// 申请失败
case ApplyHandle             = 3// 申请处理中
case ApplyAgreeNotPay        = 4// 申请通过但未打款
case ApplyPayed              = 5// 申请通过并且已经打款
}

// 项目类型
enum ProjectType: Int {
case CCLionVip               = 0// 狮子会会员项目
case Poor                    = 1// 贫困
case Medical                 = 2// 医疗
case NaturalDisaster         = 3// 自然灾害
case Education               = 4// 教育
case FirstAid                = 5// 急救
case Other                   = 6// 其他
}

// 通用Cell重用符号
let CELL_REUSE               = "COMMON_CELL_REUSE"

let SCREEN_WIDH              = UIScreen.mainScreen().bounds.width
let SCREEN_HEIGHT            = UIScreen.mainScreen().bounds.height

var VIP_ARRAY_PROJECT_TYPE   = ["狮子会"]
var NOVIP_ARRAY_PROJECT_TYPE = ["贫困", "医疗", "自然灾害", "教育", "急救", "其他"]