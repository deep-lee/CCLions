//
//  Project.swift
//  CCLions
//
//  Created by Joseph on 16/4/10.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
class Project: NSObject {
    var id: Int!
    var title: String!
    var time: String!
    var launcher_id: Int!
    var favorite: Int!
    var cover_image: String!
    var details_page: String!
    var create_time: String!
    var name: String!
    
    init(id: Int, title: String, time: String, launcher_id: Int, favorite: Int, cover_image: String, details_page: String, create_time: String, name: String ) {
        self.id = id
        self.title = title
        self.time = time
        self.launcher_id = launcher_id
        self.favorite = favorite
        self.cover_image = cover_image
        self.details_page = details_page
        self.create_time = create_time
        self.name = name
    }
}