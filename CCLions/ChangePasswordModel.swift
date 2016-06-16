//
//  ChangePasswordModel.swift
//  CCLions
//
//  Created by 李冬 on 16/6/17.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import SwiftyDrop

let CHANGE_PASSWORD_SUCCESS = "CHANGE_PASSWORD_SUCCESS"
let CHANGE_PASSWORD_FAIL = "CHANGE_PASSWORD_FAIL"

class ChangePasswordModel: SuperModel {
    /**
     获取验证码
     
     - parameter username: 手机号
     */
    func getVerCode(username: String) -> Void {
        SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: username, zone: "86", customIdentifier: nil) { (error) in
            if (error != nil) {
                Drop.down(Tips.GET_VER_CODE_FAIL, state: DropState.Error)
            } else {
                Drop.down(Tips.GET_VER_CODE_SUCCESS, state: DropState.Success)
            }
        }
    }
    
    func updatePsw(phone: String, newPsw: String, id: Int, verCode: String) -> Void {
        SVProgressHUD.show()
        // 首先判断验证码是否正确
        SMSSDK.commitVerificationCode(verCode, phoneNumber: phone, zone: "86") { (error) in
            if error != nil { // 失败
                Drop.down(Tips.VER_CODE_WRONG, state: DropState.Error)
            } else { // 成功
                // 发起注册请求
                let paras: [String: AnyObject] = [
                    "user_id": id,
                    "password": newPsw.md5,
                ]
                
                // 发起请求
                self.requestUpdatePsw(paras)
            }
        }
    }
    
    func requestUpdatePsw(paras: NSDictionary) -> Void {
        NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_UPDATE_USER_PSW.rawValue, paras: paras as! [String : AnyObject]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                SVProgressHUD.dismiss()
            case NetworkResponseState.SUCCESS.rawValue:
                // 发起认证请求成功
                self.postNotification(CHANGE_PASSWORD_SUCCESS);
                SVProgressHUD.dismiss()
            case NetworkResponseState.FAIL.rawValue:
                // 发起认证请求失败
                Drop.down(Tips.UPDATE_PASSWORD_FAIL, state: DropState.Error)
                SVProgressHUD.dismiss()
            default:
                break
            }
        }
    }
}