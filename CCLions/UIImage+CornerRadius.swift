//
//  UIImage+CornerRadius.swift
//  CCLions
//
//  Created by 李冬 on 16/3/27.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
	/**
	 扩展UIImage，给UIImage添加圆角的高效方法

	 - parameter radius: 圆角读书

	 - returns: 添加圆角后的UIImage
	 */
	func imageWithCornerRadius(radius: CGFloat) -> UIImage {
		let rect = CGRectMake(0, 0, self.size.width, self.size.height)
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		CGContextAddPath(UIGraphicsGetCurrentContext(), UIBezierPath(roundedRect: rect, cornerRadius: radius).CGPath)
		CGContextClip(UIGraphicsGetCurrentContext())
		self.drawInRect(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}
}