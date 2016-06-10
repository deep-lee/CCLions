//
//  Company.swift
//  CCLions
//
//  Created by Joseph on 16/4/13.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
class Company: NSObject {
	var id: Int!
	var user_id: Int!
	var company_name: String!
	var address_longitude: String!
	var address_latitude: String!
    var address_position: String!
	var business_scope: String!
	var industry: Int!
	var show_photo: String!
	var introduction: String!
	var contact: String!
	var create_time: String!
	var update_time: String!
	var user_name: String!
	var company_logo: String!
	var hits: Int!

	init(
        id: Int,
        user_id: Int,
        company_name: String,
        address_longitude: String,
        address_latitude: String,
        address_position: String,
        business_scope: String,
        industry: Int,
        show_photo: String,
        introduction: String,
        contact: String,
        create_time: String,
        update_time: String,
        company_logo: String,
        hits: Int
        ) {
        
        self.id                = id
        self.user_id           = user_id
        self.company_name      = company_name
        self.address_longitude = address_longitude
        self.address_latitude  = address_latitude
        self.address_position  = address_position
        self.business_scope    = business_scope
        self.industry          = industry
        self.show_photo        = show_photo
        self.introduction      = introduction
        self.contact           = contact
        self.create_time       = create_time
        self.update_time       = update_time
        self.company_logo      = company_logo
        self.hits              = hits
        
	}
}
