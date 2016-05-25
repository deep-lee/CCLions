//
//  VideoFunctions.swift
//  CCLions
//
//  Created by 李冬 on 5/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation

class VideoFunctions: NSObject {
	/**
	 获取Plist文件

	 - returns: plist文件内容
	 */
	static func getUrlInfo() -> NSDictionary? {
		let MD5PlistPath = NSBundle.mainBundle().pathForResource("bg-video-info", ofType: "plist")
		let dic = NSDictionary(contentsOfFile: MD5PlistPath!)

		return dic
	}

	/**
	 获取视频URL

	 - returns:
	 */
	static func getVideoUrl() -> String {
		let videoUrl = getUrlInfo()!["Url"] as! String

		return videoUrl
	}

	/**
	 获取视频类型

	 - returns:
	 */
	static func getVideoType() -> String {
		let type = getUrlInfo()!["Type"] as! String
		return type
	}

	/**
	 获取视频循环模式

	 - returns:
	 */
	static func getLoopMode() -> Bool {
		let loop = getUrlInfo()!["Mode Loop"] as! Bool
		return loop
	}
}
