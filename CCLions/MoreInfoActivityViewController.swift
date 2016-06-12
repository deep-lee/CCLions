//
//  MoreInfoActivityViewController.swift
//  CCLions
//
//  Created by Joseph on 16/4/25.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Eureka
import SwiftyDrop
import SwiftyJSON
import Alamofire
typealias publishActivitySendValue = () -> Void
class MoreInfoActivityViewController: FormViewController {

	var activityTheme: String!
	var activityContent: String!

	var imagerow: ImageRow!
	var dateRow: DateRow!
	var raiseMoneyRow: IntRow!
	var myClosure: publishActivitySendValue!
	var switchRow: SwitchRow!
	var idNumRow: TextRow!
	var idCardImageRow: ImageRow!
    var projectTypeRow: PushRow<String>!
    
    var isCCLionVip = false
    
    var ARRAY_PROJECT_TYPE: [String]!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
        self.initNoti()
        initWeight()
        isCCLionVip = Util.getLoginedUser()?.user_type == UserType.CCLionVip.rawValue ? true : false
        
        ARRAY_PROJECT_TYPE = isCCLionVip ? VIP_ARRAY_PROJECT_TYPE : NOVIP_ARRAY_PROJECT_TYPE
        
		imagerow = ImageRow() {
			$0.title = "封面照片"
			// $0.value = UIImage(nvard: "icon-default-header")
		}

		dateRow = DateRow() { $0.value = NSDate(); $0.title = "活动时间" }

		raiseMoneyRow = IntRow() {
			$0.title = "求助金额"
			$0.placeholder = "请输入求助金额"
		}

		switchRow = SwitchRow("是否为他人自行发起") {
			$0.title = $0.tag
		}

		idNumRow = TextRow() {
			$0.title = "受助人身份证号"
			$0.placeholder = "请输入受助人身份证号"
			$0.hidden = .Function(["是否为他人自行发起"], { form -> Bool in
				let row: RowOf<Bool>! = form.rowByTag("是否为他人自行发起")
				return row.value ?? false == false
			})
		}

		idCardImageRow = ImageRow() {
			$0.title = "受助人身份证照片"
			$0.hidden = .Function(["是否为他人自行发起"], { form -> Bool in
				let row: RowOf<Bool>! = form.rowByTag("是否为他人自行发起")
				return row.value ?? false == false
			})
		}
        
        projectTypeRow = PushRow<String>() {
            $0.title = "项目类型"
            $0.options = ARRAY_PROJECT_TYPE
            $0.value = ARRAY_PROJECT_TYPE.first
            $0.selectorTitle = "选择项目类型"
        }

		form +++
		Section("受助人信息")
		<<< imagerow
		<<< dateRow
		+++ Section("求助信息")
		<<< raiseMoneyRow
        
        +++ Section("以下部分狮子会会员不需要填写")
        <<< projectTypeRow
        <<< switchRow
        <<< idNumRow
        <<< idCardImageRow
	}

	/**
	 初始化model通知
	 */
	func initNoti() -> Void {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoreInfoActivityViewController.addActivitySuccessCallBack(_:)), name: ADD_ACTIVITY_SUCCESS, object: nil)
	}
    
    func initWeight() -> Void {
        let next = UIBarButtonItem(title: "发布", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MoreInfoActivityViewController.launch(_:)))
        self.navigationItem.rightBarButtonItem = next
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/**
	 发布活动成功通知回调

	 - parameter noti: 通知
	 */
	func addActivitySuccessCallBack(noti: NSNotification) -> Void {
		self.navigationController?.popToRootViewControllerAnimated(true)
		let rootViewController = self.navigationController?.viewControllers.first as! LaunchActivityFirstViewController
		rootViewController.clearInput()
	}
    
    /**
     获取项目类型
     
     - returns: 项目类型
     */
    func getProjectType() -> Int {
        if isCCLionVip {
            return 0
        } else {
            let index = NOVIP_ARRAY_PROJECT_TYPE.indexOf(projectTypeRow.value!)
            return index! + 1
        }
    }

    func launch(sender: AnyObject) {
		// 首先判断资料是否填写完整
		if !checkCompleted() {
			Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
			return
		}

		// self.uploadCoverImage()
		// 设置参数
		let format = NSDateFormatter()
		format.dateFormat = "yyyy-MM-dd"
		let dic = NSMutableDictionary()
		dic.setValue(activityTheme, forKey: "title")
		dic.setValue(format.stringFromDate(dateRow.value!), forKey: "time")
		dic.setValue(Util.getLoginedUser()?.id, forKey: "launcher_id")
		dic.setValue(activityContent, forKey: "details_page")
		dic.setValue(self.getProjectType(), forKey: "project_type")
		dic.setValue(raiseMoneyRow.value, forKey: "fundraising_amount")
		dic.setValue((switchRow.value == nil || switchRow.value == false) ? 0 : 1, forKey: "apply_for_other")
		dic.setValue(idNumRow.value, forKey: "aided_person_id_num")
		if switchRow.value == nil || switchRow.value == false {
			// 未自己发布
			dic.setValue("", forKey: "aided_person_id_card_photo")
			dic.setValue("", forKey: "aided_person_id_num")
		} else {
			// 为别人发布
			dic.setValue(idNumRow.value, forKey: "aided_person_id_num")
		}

		LaunchActivityModel.shareInstance().uploadCoverImage(dic, coverImage: imagerow.value!, idCardImage: idCardImageRow.value)
	}

	func setClosure(closure: publishActivitySendValue) -> Void {
		self.myClosure = closure
	}

	/**
	 检查资料是否填写完整

	 - returns:
	 */
	func checkCompleted() -> Bool {
		// print(projectTypeRow.value)
		if self.imagerow.value != nil
		&& self.dateRow.cell.detailTextLabel?.text != nil
		&& raiseMoneyRow.value != nil
		&& (switchRow.value == nil || switchRow.value == false) ? (true) : (idNumRow.value != nil && idCardImageRow.value != nil) {
			return true
		}
		return false
	}
}
