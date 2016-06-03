//
//  SuperModel.swift
//  CCLions
//
//  Created by Joseph on 16/5/20.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import SwiftyJSON

class SuperModel: NSObject {
    func postNotification(name: String) -> Void {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil);
    }
    
    /**
     更新登录的用户信息
     */
    func updateLoginedUserInfo() -> Void {
        if Util.hasUserLogined() {
            let paras = [
                "userId": "\(Util.getLoginedUser()?.id)"
            ]
            
            NetworkUtil.shareInstance().requestWithUrlWithReturnDictionary(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_USER_INFO_WITH_ID.rawValue, paras: paras, networkResponse: { (response) in
                let state = response.objectForKey(NETWORK_STATE) as! Int
                if state == NetworkResponseState.SUCCESS.rawValue {
                    let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [String: AnyObject]
                    let data = JSON(dataString)
                    let user = User(id: data["id"].intValue,
                        username: data["username"].stringValue,
                        password: data["password"].stringValue,
                        header: data["header"].stringValue,
                        name: data["name"].stringValue,
                        sex: data["sex"].intValue,
                        address: data["address"].stringValue,
                        contact: data["contact"].stringValue,
                        user_type: data["user_type"].intValue,
                        service_team: data["service_team"].stringValue,
                        authentication_status: data["authentication_status"].intValue,
                        update_time: data["update_time"].stringValue)
                    
                    // 存储登录用户的信息
                    Util.updateUser(user)
                }
            })
        }
    }
}
