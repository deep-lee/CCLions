//
//  ProjectWithdrawRecordModel.swift
//  CCLions
//
//  Created by 李冬 on 6/7/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import SwiftyDrop
import SwiftyJSON

let PROJECT_WITHDRAW_REFRESH_DATA_SUCCESS = "PROJECT_WITHDRAW_REFRESH_DATA_SUCCESS"
let PROJECT_WITHDRAW_REFRESH_DATA_FINISH = "PROJECT_WITHDRAW_REFRESH_DATA_FINISH"
let PROJECT_WITHDRAW_LOAD_MORE_DATA_SUCCESS = "PROJECT_WITHDRAW_LOAD_MORE_DATA_SUCCESS"
let PROJECT_WITHDRAW_LOAD_MORE_DATA_FINISH = "PROJECT_WITHDRAW_LOAD_MORE_DATA_FINISH"

class ProjectWithdrawRecordModel: SuperModel {
    var dataArray: [Withdraw]!
    var lastId = Int.max // 已展示的最后一条数据的id
    var project_id: Int!
    // 单例
    class func shareInstance() -> ProjectWithdrawRecordModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: ProjectWithdrawRecordModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = ProjectWithdrawRecordModel()
            Singleton.single?.dataArray = [Withdraw]()
            }
        )
        return Singleton.single!
    }
    
    func refresh() -> Void {
        self.lastId = Int.max
        let paras = [
            "lastId": self.lastId,
            "project_id": self.project_id
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_WITHDRAW_RECORD_BY_PAGE.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(PROJECT_WITHDRAW_REFRESH_DATA_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let withdraw = Util.getWithdrawFromJson(item)
                        self.dataArray.append(withdraw)
                    }
                    // 重新加载TableView数据
                    print(self.dataArray)
                    self.postNotification(PROJECT_WITHDRAW_REFRESH_DATA_SUCCESS)
                    print(self.dataArray.last?.id)
                    self.lastId = (self.dataArray.last?.id)!
                } else {
                    self.postNotification(PROJECT_WITHDRAW_REFRESH_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(PROJECT_WITHDRAW_REFRESH_DATA_FINISH)
            default:
                break
            }
        }
    }
    
    func loadMore() -> Void {
        let paras = [
            "lastId": self.lastId,
            "project_id": self.project_id
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_WITHDRAW_RECORD_BY_PAGE.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(PROJECT_WITHDRAW_LOAD_MORE_DATA_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let withdraw = Util.getWithdrawFromJson(item)
                        self.dataArray.append(withdraw)
                    }
                    // 重新加载TableView数据
                    self.postNotification(PROJECT_WITHDRAW_LOAD_MORE_DATA_SUCCESS)
                    self.lastId = (self.dataArray.last?.id)!
                } else {
                    self.postNotification(PROJECT_WITHDRAW_LOAD_MORE_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(PROJECT_WITHDRAW_LOAD_MORE_DATA_FINISH)
            default:
                break
            }
        }
    }
}