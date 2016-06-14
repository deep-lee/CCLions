//
//  LaunchedProjectModel.swift
//  CCLions
//
//  Created by 李冬 on 6/14/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import Foundation
import SwiftyDrop
import SwiftyJSON

let LAUNCHED_PROJECT_REFRESH_DATA_SUCCESS = "LAUNCHED_PROJECT_REFRESH_DATA_SUCCESS"
let LAUNCHED_PROJECT_REFRESH_DATA_FINISH  = "LAUNCHED_PROJECT_REFRESH_DATA_FINISH"
let LAUNCHED_PROJECT_LOAD_MORE_SUCCESS    = "LAUNCHED_PROJECT_LOAD_MORE_SUCCESS"
let LAUNCHED_PROJECT_LOAD_MORE_FINISH     = "LAUNCHED_PROJECT_LOAD_MORE_FINISH"

class LaunchedProjectModel: SuperModel {
    var row = 0
    var dataArray: [Project]!
    // 单例
    class func shareInstance() -> LaunchedProjectModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: LaunchedProjectModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = LaunchedProjectModel()
            Singleton.single?.dataArray = [Project]()
            }
        )
        return Singleton.single!
    }
    
    func requestLAUNCHEDProject() -> Void {
        let paras = [
            "user_id": "\(Util.getLoginedUser()!.id)",
            "row": 0
        ]
        
        print(paras)
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_MY_LAUNCHED_PROJECT.rawValue, paras: paras as! [String : AnyObject]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(LAUNCHED_PROJECT_REFRESH_DATA_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let project = Util.getProjectFromJson(item)
                        self.dataArray.append(project)
                    }
                    // 重新加载TableView数据
                    self.postNotification(LAUNCHED_PROJECT_REFRESH_DATA_SUCCESS)
                } else {
                    self.postNotification(LAUNCHED_PROJECT_REFRESH_DATA_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(LAUNCHED_PROJECT_REFRESH_DATA_FINISH)
            default:
                break
            }
        }
    }
    
    func loadMoreLAUNCHEDProject() -> Void {
        let paras = [
            "user_id": "\(Util.getLoginedUser()!.id)",
            "row": self.dataArray.count
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnArray(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_GET_MY_LAUNCHED_PROJECT.rawValue, paras: paras as! [String : AnyObject]) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                self.postNotification(LAUNCHED_PROJECT_LOAD_MORE_FINISH)
            case NetworkResponseState.SUCCESS.rawValue:
                let dataString = response.objectForKey(NETWORK_SUCCESS_DATA) as! [AnyObject]
                let data = JSON(dataString).arrayValue
                if data.count != 0 {
                    self.dataArray.removeAll()
                    for item in data {
                        let project = Util.getProjectFromJson(item)
                        self.dataArray.append(project)
                    }
                    // 重新加载TableView数据
                    self.postNotification(LAUNCHED_PROJECT_REFRESH_DATA_SUCCESS)
                } else {
                    self.postNotification(LAUNCHED_PROJECT_LOAD_MORE_FINISH)
                }
            case NetworkResponseState.FAIL.rawValue:
                Drop.down(Tips.REFRESH_MAIN_PROJECT_FAIL, state: DropState.Error)
                self.postNotification(LAUNCHED_PROJECT_LOAD_MORE_FINISH)
            default:
                break
            }
        }
    }

}