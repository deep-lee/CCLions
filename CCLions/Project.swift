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
	var project_type: Int!
	var fundraising_amount: Int!
	var has_raised_amount: Int!
	var withdraw_amount: Int!
	var create_time: String!
	var name: String!

	init(id: Int, title: String, time: String,
		launcher_id: Int, favorite: Int, cover_image: String,
		details_page: String, project_type: Int, fundraising_amount: Int!,
		has_raised_amount: Int!, withdraw_amount: Int!, create_time: String, name: String) {

			self.id = id
			self.title = title
			self.time = time
			self.launcher_id = launcher_id
			self.favorite = favorite
			self.cover_image = cover_image
			self.details_page = details_page
			self.project_type = project_type
			self.fundraising_amount = fundraising_amount
			self.has_raised_amount = has_raised_amount
			self.withdraw_amount = withdraw_amount
			self.create_time = create_time
			self.name = name
	}
}