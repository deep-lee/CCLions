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
    var myClosure: publishActivitySendValue!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
         imagerow = ImageRow(){
            $0.title = "封面照片"
            // $0.value = UIImage(named: "icon-default-header")
        }
        
        dateRow = DateRow() { $0.value = NSDate(); $0.title = "活动时间" }
        
        form  +++
            Section("")
            <<< imagerow
            <<< dateRow
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func launch(sender: AnyObject) {
        // 首先判断资料是否填写完整
        if !checkCompleted() {
            Drop.down(Tips.USER_INFO_NOT_COMPLETED, state: DropState.Warning)
            return
        }
        
        self.uploadCoverImage()
    }
    
    /**
     上传封面照片
     */
    func uploadCoverImage() -> Void {
        SVProgressHUD.showWithStatus(Tips.ADDING_ACTIVITY)
//        Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_ACTIVITY_IMAGE.rawValue, file: self.imagerow.imageURL!)
//            .responseJSON(completionHandler: { (response) in
//                if let value = response.result.value {
//                    
//                    print(value)
//                    // 解析JSON
//                    let json = JSON(value)
//                    let code = json["code"].intValue
//                    if code == 200 { // 上传成功
//                        let data = json["data"].stringValue
//                        // 更新资料
//                        self.requestAddActivity(data)
//                    } else {  // 上传失败
//                        Drop.down(Tips.ADD_ACTIVITY_FAIL, state: DropState.Error)
//                        SVProgressHUD.dismiss()
//                    }
//                } else { // 返回为空，说明网络连接失败
//                    Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
//                    SVProgressHUD.dismiss()
//                }
//            })
        
        Alamofire.upload(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ACCEPT_ACTIVITY_IMAGE.rawValue, data: UIImageJPEGRepresentation(self.imagerow.value! as UIImage, 0.5)!)
            .responseJSON(completionHandler: { (response) in
                if let value = response.result.value {
                    
                    print(value)
                    // 解析JSON
                    let json = JSON(value)
                    let code = json["code"].intValue
                    if code == 200 { // 上传成功
                        let data = json["data"].stringValue
                        // 更新资料
                        self.requestAddActivity(HttpRequest.HTTP_ADDRESS + data)
                    } else {  // 上传失败
                        Drop.down(Tips.ADD_ACTIVITY_FAIL, state: DropState.Error)
                        SVProgressHUD.dismiss()
                    }
                } else { // 返回为空，说明网络连接失败
                    Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                    SVProgressHUD.dismiss()
                }
            })
    }
    
    func setClosure(closure: publishActivitySendValue) -> Void {
        self.myClosure = closure
    }
    
    /**
     请求发起新的活动
     */
    func requestAddActivity(coverImageAddress: String) -> Void {
        let paras: [String: AnyObject] = [
            "title": self.activityTheme,
            "time": (self.dateRow.cell.detailTextLabel?.text)!,
            "launcher_id":(Util.getLoginedUser()?.id)!,
            "cover_image": coverImageAddress,
            "details_page": activityContent
        ]
        
        Alamofire.request(.POST, HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_ACTIVITY.rawValue, parameters: paras)
        .responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                let code = json["code"].intValue
                if code == 200 {
                    // 发起成功
                    Drop.down(Tips.ADD_ACTIVITY_SUCCESS, state: DropState.Success)
                    if (self.myClosure != nil) {
                        self.myClosure()
                    }
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    // 发起失败
                    Drop.down(Tips.ADD_ACTIVITY_FAIL, state: DropState.Error)
                }
            } else {
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    /**
     检查资料是否填写完整
     
     - returns:
     */
    func checkCompleted() -> Bool {
        if self.imagerow.value != nil && self.dateRow.cell.detailTextLabel?.text != nil {
            return true
        }
        
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
