//
//  Withdraw.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

class Withdraw: NSObject {
    var id: Int?                        // 提款记录id
    var name: String?                   // 提款人姓名
    var header: String?                 // 提款人头像
    var contact: String?                // 提款人联系方式
    var user_type: Int?                 // 提款人用户类型
    var user_id: Int?                   // 提款人id
    var project_id: Int?                // 提款项目id
    var amount: Int?                    // 提款金额
    var application: String?       // 提款金额用途
    var prove: String?                  // 上传的证明材料地址
    var status: Int?                    // 提款记录的状态
    var message: String?                // 后台反馈的消息
    
    init(
        id: Int?,
        name: String?,
        header: String?,
        contact: String?,
        user_type: Int?,
        user_id: Int?,
        project_id: Int?,
        amount: Int?,
        application: String?,
        prove: String?,
        status: Int?,
        message: String?
        ) {
        self.id = id
        self.name = name
        self.header = header
        self.contact = contact
        self.user_type = user_type
        self.user_id = user_id
        self.project_id = project_id
        self.amount = amount
        self.application = application
        self.prove = prove
        self.status = status
        self.message = message
    }
}