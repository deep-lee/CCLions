//
//  NSObject+Statistics.swift
//  CCLions
//
//  Created by 李冬 on 16/5/8.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation

extension NSObject {
	/**
	 自定义统计项

	 - parameter name: 统计项的名字
	 */
	func flurryStatisticsWithName(name: String) -> Void {
		Flurry.logEvent(name)
	}

	/**
	 自定义统计项，统计次数

	 - parameter name:  统计项名字
	 - parameter paras: 次数分布
	 */
	func flurryStatisticsWithName(name: String, paras: [NSObject: AnyObject]!) -> Void {
		print("正在记录信息")
		Flurry.logEvent(name, withParameters: paras)
	}
}