//
//  HotIndustry.swift
//  CCLions
//
//  Created by 李冬 on 16/4/30.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import UIKit
class HotIndustry: NSObject {
	var id: Int!
	var industry: Int!
	var show_photo: String!

	init(id: Int, industry: Int, show_photo: String) {
		super.init()
		self.id = id
		self.industry = industry
		self.show_photo = show_photo
	}
}
