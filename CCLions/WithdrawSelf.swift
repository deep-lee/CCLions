//
//  WithdrawSelf.swift
//  CCLions
//
//  Created by 李冬 on 16/6/15.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
class WithdrawSelf: NSObject {
    var id: Int?                        // 提款记录id
    var contact: String?                // 提款人联系方式
    var user_id: Int?                   // 提款人id
    var project_id: Int?                // 提款项目id
    var amount: Int?                    // 提款金额
    var application: String?            // 提款金额用途
    var prove: String?                  // 上传的证明材料地址
    var status: Int?                    // 提款记录的状态
    var message: String?                // 后台反馈的消息
    var title: String?                  // 项目标题
    
    init(
        id: Int?,
        contact: String?,
        user_id: Int?,
        project_id: Int?,
        amount: Int?,
        application: String?,
        prove: String?,
        status: Int?,
        message: String?,
        title: String?
        ) {
        self.id = id
        self.contact = contact
        self.user_id = user_id
        self.project_id = project_id
        self.amount = amount
        self.application = application
        self.prove = prove
        self.status = status
        self.message = message
        self.title = title
    }
}