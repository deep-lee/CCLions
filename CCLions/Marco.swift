//
//  Marco.swift
//  CCLions
//
//  Created by 李冬 on 6/1/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

let GAODE_APIKey                                 = "c8ae2ff34b5f1a87bd61304e1f75dba9"

// 用户类型
enum UserType: Int {
case CCLionVip                                   = 1
case NonVip                                      = 0
}

// 用户认证状态
enum UserAuthenticationStatus: Int {
case NotAuthentication                           = 0// 未认证
case InAuthentication                            = 1// 认证中
case FailAuthentication                          = 2// 认证失败
case SuccessAuthentication                       = 3// 通过认证
}

// 提款状态
enum WithdrawStatus: Int {
case ApplyIn                                     = 1// 申请中
case ApplyFail                                   = 2// 申请失败
case ApplyHandle                                 = 3// 申请处理中
case ApplyAgreeNotPay                            = 4// 申请通过但未打款
case ApplyPayed                                  = 5// 申请通过并且已经打款
}

// 项目类型
enum ProjectType: Int {
case CCLionVip                                   = 0// 狮子会会员项目
case Poor                                        = 1// 贫困
case Medical                                     = 2// 医疗
case NaturalDisaster                             = 3// 自然灾害
case Education                                   = 4// 教育
case FirstAid                                    = 5// 急救
case Other                                       = 6// 其他
}

// 通用Cell重用符号
let CELL_REUSE                                   = "COMMON_CELL_REUSE"

let SCREEN_WIDH                                  = UIScreen.mainScreen().bounds.width
let SCREEN_HEIGHT                                = UIScreen.mainScreen().bounds.height

let MAIN_CELL_HEIGHT: CGFloat                    = 322
let FLOW_BUTTON_BIG_WIDTH                        = 45
let FLOW_BUTTON_SMALL_WIDTH                      = 35
let FLOW_BUTTON_ALPHA: Float                     = 1.0
let FLOW_BOTTOM_OFFSET                           = -10
let PROGRESS_VIEW_HEIGHT: CGFloat                = 5
let DONATION_AMOUNT_SUGGEST_CELL_HEIGHT: CGFloat = 69
let HEIGHT_FOR_SUPPORTED_PROJECT_CELL: CGFloat   = 434
let HEIGHT_FOR_LAUNCHED_PROJECT_CELL: CGFloat    = 444
let HEIGHT_FOR_WITHDRAW_RECORD_CELL: CGFloat     = 160

var VIP_ARRAY_PROJECT_TYPE                       = ["狮子会"]
var NOVIP_ARRAY_PROJECT_TYPE                     = ["贫困", "医疗", "自然灾害", "教育", "急救", "其他"]

var ARRAY_DEFAULT_SUGGEST_DONATION_MONEY         = [
    DonationSuggestionMoney(id: 1, amount: 5, create_time: nil),
    DonationSuggestionMoney(id: 2, amount: 10, create_time: nil),
    DonationSuggestionMoney(id: 3, amount: 20, create_time: nil),
    DonationSuggestionMoney(id: 4, amount: 50, create_time: nil),
    DonationSuggestionMoney(id: 5, amount: 100, create_time: nil),
    DonationSuggestionMoney(id: 6, amount: 200, create_time: nil),
    DonationSuggestionMoney(id: 7, amount: 500, create_time: nil),
]

let SELECT_COMPANY_POSITION_BUTTON_CLICKED       = "SELECT_COMPANY_POSITION_BUTTON_CLICKED"
let POSITION_LATITUDE                            = "POSITION_LATITUDE"
let POSITION_LONGITUDE                           = "POSITION_LONGITUDE"
let POSITION_TITLE                               = "POSITION_TITLE"
let DETAILS_BUTTON_CLICKED                       = "DETAILS_BUTTON_CLICKED"
let COMOPANY_NAME                                = "COMOPANY_NAME"
let CURRENT_POSITION                             = "当前位置"