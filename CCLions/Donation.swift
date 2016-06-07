//
//  Donation.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

/// 捐款记录表
class Donation: NSObject {
	var id: Int? // 捐款记录id
	var header: String? // 捐款人头像
	var name: String? // 捐款人姓名
	var user_type: Int? // 捐款人类型
	var user_id: Int? // 捐款人id
	var project_id: Int? // 求助项目id
	var amount: Int? // 捐款金额
	var application: String? // 捐款金额用途

	init(
		id: Int?,
		header: String?,
		name: String?,
		user_type: Int?,
		user_id: Int?,
		project_id: Int?,
		amount: Int?,
		application: String?
	) {
		self.id = id
		self.header = header
		self.name = name
		self.user_type = user_type
		self.user_id = user_id
		self.project_id = project_id
		self.amount = amount
		self.application = application
	}
}