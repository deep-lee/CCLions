//
//  UIViewControllerExtension.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit

extension UIViewController {
	func setNavigationBarItem() {
		self.slideMenuController()?.removeLeftGestures()
		self.slideMenuController()?.removeRightGestures()
		self.slideMenuController()?.addLeftGestures()
		self.slideMenuController()?.addRightGestures()
	}

	func removeNavigationBarItem() {
		self.navigationItem.leftBarButtonItem = nil
		self.navigationItem.rightBarButtonItem = nil
		self.slideMenuController()?.removeLeftGestures()
		self.slideMenuController()?.removeRightGestures()
	}
    
    func showTipsAlertWithTwoBtn(
        message: String,
        okString: String,
        cancleString: String,
        okAction: ((UIAlertAction) -> Void),
        cancleAction: ((UIAlertAction) -> Void)
        ) -> Void {
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: okString, style: UIAlertActionStyle.Default, handler: okAction)
        let cancleAction = UIAlertAction(title: cancleString, style: UIAlertActionStyle.Cancel, handler: cancleAction)
        alertController.addAction(okAction)
        alertController.addAction(cancleAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showTipsAlertWithOneBtn(message: String,
                                 okString: String,
                                 okAction: ((UIAlertAction) -> Void)) -> Void {
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: okString, style: UIAlertActionStyle.Default, handler: okAction)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}