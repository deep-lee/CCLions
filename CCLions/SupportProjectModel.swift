//
//  SupportProjectModel.swift
//  CCLions
//
//  Created by 李冬 on 6/13/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import SwiftyDrop
import SwiftyJSON

let SUPPORTED_PROJECT_REFRESH_DATA_SUCCESS = "SUPPORTED_PROJECT_REFRESH_DATA_SUCCESS"
let SUPPORTED_PROJECT_REFRESH_DATA_FINISH  = "SUPPORTED_PROJECT_REFRESH_DATA_FINISH"
let SUPPORTED_PROJECT_LOAD_MORE_SUCCESS    = "SUPPORTED_PROJECT_LOAD_MORE_SUCCESS"
let SUPPORTED_PROJECT_LOAD_MORE_FINISH     = "SUPPORTED_PROJECT_LOAD_MORE_FINISH"

class SupportProjectModel: SuperModel {
    
    var row = 0
    var dataArray: [SupportedProject]!
    // 单例
    class func shareInstance() -> SupportProjectModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: SupportProjectModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = SupportProjectModel()
            Singleton.single?.dataArray = [SupportedProject]()
            }
        )
        return Singleton.single!
    }
    
    func requestSupportedProject() -> Void {
        let paras = [
            "user_id": "\(Util.getLoginedUser()!.id)",
            "row": 0
        ]
        
        print(paras)
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_SUPPORTED_PROJECT.rawValue, paras: paras as! [String : AnyObject]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(SUPPORTED_PROJECT_REFRESH_DATA_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let supportedProject = Util.getSupportedProjectFromJson(item)
                        self.dataArray.append(supportedProject)
                    }
                    // 重新加载TableView数据
                    self.postNotification(SUPPORTED_PROJECT_REFRESH_DATA_SUCCESS)
                } else {
                    self.postNotification(SUPPORTED_PROJECT_REFRESH_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(SUPPORTED_PROJECT_REFRESH_DATA_FINISH)
            default:
                break
            }
        }
    }
    
    func loadMoreSupportedProject() -> Void {
        let paras = [
            "user_id": "\(Util.getLoginedUser()!.id)",
            "row": self.dataArray.count
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_SUPPORTED_PROJECT.rawValue, paras: paras as! [String : AnyObject]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(SUPPORTED_PROJECT_LOAD_MORE_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let supportedProject = Util.getSupportedProjectFromJson(item)
                        self.dataArray.append(supportedProject)
                    }
                    // 重新加载TableView数据
                    self.postNotification(SUPPORTED_PROJECT_REFRESH_DATA_SUCCESS)
                } else {
                    self.postNotification(SUPPORTED_PROJECT_LOAD_MORE_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(SUPPORTED_PROJECT_LOAD_MORE_FINISH)
            default:
                break
            }
        }
    }
    
}