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
	var apply_for_other: Int! // 是否为为别人申请
	var aided_person_id_num: String! // 受助人身份证号
	var aided_person_id_card_photo: String! // 受助人身份证照片
	var left_time: Int! // 剩余时间
	var sponsorship_company_id: Int! // 冠名企业id
	var create_time: String!
	var name: String!

	init(id: Int,
		title: String,
		time: String,
		launcher_id: Int,
		favorite: Int,
		cover_image: String,
		details_page: String,
		project_type: Int,
		fundraising_amount: Int!,
		has_raised_amount: Int!,
		withdraw_amount: Int!,
		apply_for_other: Int,
		aided_person_id_num: String,
		aided_person_id_card_photo: String,
		left_time: Int,
		sponsorship_company_id: Int,
		create_time: String,
		name: String) {

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
			self.apply_for_other = apply_for_other
			self.aided_person_id_num = aided_person_id_num
			self.aided_person_id_card_photo = aided_person_id_card_photo
			self.left_time = left_time
			self.sponsorship_company_id = sponsorship_company_id
			self.create_time = create_time
			self.name = name
	}
}