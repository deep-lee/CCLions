//
//  Project.swift
//  CCLions
//
//  Created by Joseph on 16/4/10.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
class Project: NSObject, NSCoding {
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
    var header: String!

	init(
        id: Int,
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
		name: String,
        header: String
        ) {

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
            self.header = header
	}
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.time, forKey: "time")
        aCoder.encodeObject(self.launcher_id, forKey: "launcher_id")
        aCoder.encodeObject(self.favorite, forKey: "favorite")
        aCoder.encodeObject(self.cover_image, forKey: "cover_image")
        aCoder.encodeObject(self.details_page, forKey: "details_page")
        aCoder.encodeObject(self.project_type, forKey: "project_type")
        aCoder.encodeObject(self.fundraising_amount, forKey: "fundraising_amount")
        aCoder.encodeObject(self.has_raised_amount, forKey: "has_raised_amount")
        aCoder.encodeObject(self.withdraw_amount, forKey: "withdraw_amount")
        aCoder.encodeObject(self.apply_for_other, forKey: "apply_for_other")
        aCoder.encodeObject(self.aided_person_id_num, forKey: "aided_person_id_num")
        aCoder.encodeObject(self.aided_person_id_card_photo, forKey: "aided_person_id_card_photo")
        aCoder.encodeObject(self.left_time, forKey: "left_time")
        aCoder.encodeObject(self.sponsorship_company_id, forKey: "sponsorship_company_id")
        aCoder.encodeObject(self.create_time, forKey: "create_time")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.header, forKey: "header")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        id = aDecoder.decodeObjectForKey("id") as! Int
        self.title = aDecoder.decodeObjectForKey("title") as! String
        self.time = aDecoder.decodeObjectForKey("time") as! String
        self.launcher_id = aDecoder.decodeObjectForKey("launcher_id") as! Int
        self.favorite = aDecoder.decodeObjectForKey("favorite") as! Int
        self.cover_image = aDecoder.decodeObjectForKey("cover_image") as! String
        self.details_page = aDecoder.decodeObjectForKey("details_page") as! String
        self.project_type = aDecoder.decodeObjectForKey("project_type") as! Int
        self.fundraising_amount = aDecoder.decodeObjectForKey("fundraising_amount") as! Int
        self.has_raised_amount = aDecoder.decodeObjectForKey("has_raised_amount") as! Int
        self.withdraw_amount = aDecoder.decodeObjectForKey("withdraw_amount") as! Int
        self.apply_for_other = aDecoder.decodeObjectForKey("apply_for_other") as! Int
        self.aided_person_id_num = aDecoder.decodeObjectForKey("aided_person_id_num") as! String
        self.aided_person_id_card_photo = aDecoder.decodeObjectForKey("aided_person_id_card_photo") as! String
        self.left_time = aDecoder.decodeObjectForKey("left_time") as! Int
        self.sponsorship_company_id = aDecoder.decodeObjectForKey("sponsorship_company_id") as! Int
        self.create_time = aDecoder.decodeObjectForKey("create_time") as! String
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.header = aDecoder.decodeObjectForKey("header") as! String

        
    }
}