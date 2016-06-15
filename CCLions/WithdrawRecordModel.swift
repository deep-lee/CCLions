//
//  WithdrawRecordModel.swift
//  CCLions
//
//  Created by 李冬 on 16/6/15.
//  Copyright © 2016年 李冬. All rights reserved.
//

import Foundation
import SwiftyDrop
import SwiftyJSON

let WITHDRAW_RECORD_REFRESH_DATA_SUCCESS = "WITHDRAW_RECORD_REFRESH_DATA_SUCCESS"
let WITHDRAW_RECORD_REFRESH_DATA_FINISH  = "WITHDRAW_RECORD_REFRESH_DATA_FINISH"
let WITHDRAW_RECORD_LOAD_MORE_SUCCESS    = "WITHDRAW_RECORD_LOAD_MORE_SUCCESS"
let WITHDRAW_RECORD_LOAD_MORE_FINISH     = "WITHDRAW_RECORD_LOAD_MORE_FINISH"

class WithdrawRecordModel: SuperModel {
    
    var dataArray: [WithdrawSelf]!
    
    // 单例
    class func shareInstance() -> WithdrawRecordModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: WithdrawRecordModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = WithdrawRecordModel()
            Singleton.single?.dataArray = [WithdrawSelf]()
            }
        )
        return Singleton.single!
    }
    
    func refresh() -> Void {
        let paras = [
            "user_id": Util.getLoginedUser()!.id,
            "row": 0
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_WITHDRAW_SELF_BY_ROW.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(WITHDRAW_RECORD_REFRESH_DATA_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let withdraw = Util.getWithdrawSelfFromJson(item)
                        self.dataArray.append(withdraw)
                    }
                    // 重新加载TableView数据
                    self.postNotification(WITHDRAW_RECORD_REFRESH_DATA_SUCCESS)
                } else {
                    self.postNotification(WITHDRAW_RECORD_REFRESH_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(WITHDRAW_RECORD_REFRESH_DATA_FINISH)
            default:
                break
            }
        }
    }
    
    func loadMore() -> Void {
        let paras = [
            "user_id": "\(Util.getLoginedUser()!.id)",
            "row": self.dataArray.count
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_WITHDRAW_SELF_BY_ROW.rawValue, paras: paras as! [String : AnyObject]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(WITHDRAW_RECORD_LOAD_MORE_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let withdraw = Util.getWithdrawSelfFromJson(item)
                        self.dataArray.append(withdraw)
                    }
                    // 重新加载TableView数据
                    self.postNotification(WITHDRAW_RECORD_REFRESH_DATA_SUCCESS)
                } else {
                    self.postNotification(WITHDRAW_RECORD_LOAD_MORE_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(WITHDRAW_RECORD_LOAD_MORE_FINISH)
            default:
                break
            }
        }
    }
}