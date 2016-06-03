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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imagerow = ImageRow() {
            $0.title = "封面照片"
            // $0.value = UIImage(named: "icon-default-header")
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
        
        form +++
            Section("受助人信息")
            <<< imagerow
            <<< dateRow
            +++ Section("求助信息")
            <<< raiseMoneyRow
            
            // 以下是非狮子会会员求助需要填写的信息
            <<< switchRow
            <<< idNumRow
            <<< idCardImageRow
        
        self.initNoti()
    }
    
    /**
     初始化model通知
     */
    func initNoti() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoreInfoActivityViewController.addActivitySuccessCallBack(_:)), name: ADD_ACTIVITY_SUCCESS, object: nil)
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
    }
    
    @IBAction func launch(sender: AnyObject) {
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
        dic.setValue(Util.getLoginedUser()?.user_type == UserType.CCLionVip.rawValue ? 1 : 0, forKey: "project_type")
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
        print(switchRow.value)
        if self.imagerow.value != nil
            && self.dateRow.cell.detailTextLabel?.text != nil
            && raiseMoneyRow.value != nil
            && (switchRow.value == nil || switchRow.value == false) ? (true) : (idNumRow.value != nil && idCardImageRow.value != nil) {
            return true
        }
        return false
    }
}
