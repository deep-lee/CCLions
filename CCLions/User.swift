//
//  User.swift
//  CCLions
//
//  Created by Joseph on 16/4/9.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
	var id: Int!
	var username: String!
	var password: String!
	var header: String!
	var name: String!
	var sex: Int!
	var address: String!
	var contact: String!
	var service_team: String!
	var update_time: String!

	init(id: Int, username: String, password: String, header: String, name: String, sex: Int, address: String, contact: String, service_team: String, update_time: String) {
        self.id           = id
        self.username     = username
        self.password     = password
        self.header       = header
        self.name         = name
        self.sex          = sex
        self.address      = address
        self.contact      = contact
        self.service_team = service_team
        self.update_time  = update_time
	}

	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(self.id, forKey: "id")
		aCoder.encodeObject(self.username, forKey: "username")
		aCoder.encodeObject(self.password, forKey: "password")
		aCoder.encodeObject(self.header, forKey: "header")
		aCoder.encodeObject(self.name, forKey: "name")
		aCoder.encodeObject(self.sex, forKey: "sex")
		aCoder.encodeObject(self.address, forKey: "address")
		aCoder.encodeObject(self.contact, forKey: "contact")
		aCoder.encodeObject(self.service_team, forKey: "service_team")
		aCoder.encodeObject(self.update_time, forKey: "update_time")
	}

	required init?(coder aDecoder: NSCoder) {
		super.init()
        id                = aDecoder.decodeObjectForKey("id") as! Int
        self.username     = aDecoder.decodeObjectForKey("username") as! String
        self.password     = aDecoder.decodeObjectForKey("password") as! String
        self.header       = aDecoder.decodeObjectForKey("header") as! String
        self.name         = aDecoder.decodeObjectForKey("name") as! String
        self.sex          = aDecoder.decodeObjectForKey("sex") as! Int
        self.address      = aDecoder.decodeObjectForKey("address") as! String
        self.contact      = aDecoder.decodeObjectForKey("contact") as! String
        self.service_team = aDecoder.decodeObjectForKey("service_team") as! String
        self.update_time  = aDecoder.decodeObjectForKey("update_time") as! String

	}
}