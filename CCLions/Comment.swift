//
//  Comment.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

class Comment: NSObject {
    var id: Int?                        // 评论记录id
    var header: String?                 // 评论用户头像
    var name: String?                   // 评论用户名字
    var user_type: Int?                 // 评论用户类型
    var project_id: Int?                // 评论项目id
    var user_id: Int?                   // 评论用户id
    var content: String?                // 评论内容
    var create_time: String?            // 评论时间
    
    init(
        id: Int?,
        header: String?,
        name: String?,
        user_type: Int?,
        project_id: Int?,
        user_id: Int?,
        content: String?,
        create_time: String?
        ) {
        self.id = id
        self.header = header
        self.name = name
        self.user_type = user_type
        self.project_id = project_id
        self.user_id = user_id
        self.content = content
        self.create_time = create_time
    }
}