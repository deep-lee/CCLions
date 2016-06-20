//
//  ProjectDetailsModel.swift
//  CCLions
//
//  Created by 李冬 on 6/8/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import SwiftyDrop

let CHECK_USER_HAS_LOVED_PROJECT = "CHECK_USER_HAS_LOVED_PROJECT"
let CHECK_LOVED_RECULT           = "CHECK_LOVED_RECULT"
let ADD_FAV_SUCCESS              = "ADD_FAV_SUCCESS"
let DELETE_FAV_SUCCESS           = "DELETE_FAV_SUCCESS"

class ProjectDetailsModel: SuperModel {
    // 单例
    class func shareInstance() -> ProjectDetailsModel {
        struct Singleton {
            static var onceToken: dispatch_once_t = 0
            static var single: ProjectDetailsModel?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = ProjectDetailsModel()
            }
        )
        return Singleton.single!
    }
    
    /**
     判断当前用户对项目是否点赞了
     
     - parameter project_id: 项目id
     */
    func checkUserHasLovedProject(project_id: Int) -> Void {
        
        if !Util.hasUserLogined() {
            return
        }
        
        let paras = [
            "user_id": Util.getLoginedUser()!.id,
            "project_id": project_id
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_HAS_USER_LOVED_PROJECT.rawValue, paras: paras) { (response) in
            print(response)
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                // Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                break
            case NetworkResponseState.SUCCESS.rawValue:
                // 获取信息成功
                let object = NSMutableDictionary()
                
                object.setValue(response.objectForKey(NETWORK_SUCCESS_DATA), forKey: CHECK_LOVED_RECULT)
                self.postNotificationWithName(CHECK_USER_HAS_LOVED_PROJECT, object: object)
            case NetworkResponseState.FAIL.rawValue:
                // Drop.down(Tips.GET_MORE_PROJECT_DETAILS_ERROR, state: DropState.Error)
                break
            default:
                break
            }
        }
    }
    
    /**
      点赞
     
     - parameter project_id: 项目id
     */
    func addFav(project_id: Int) -> Void {
        let paras = [
            "user_id": Util.getLoginedUser()!.id,
            "project_id": project_id
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_ADD_FAV.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                // Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                break
            case NetworkResponseState.SUCCESS.rawValue:
                // 点赞成功
                self.postNotification(ADD_FAV_SUCCESS)
            case NetworkResponseState.FAIL.rawValue:
                // Drop.down(Tips.GET_MORE_PROJECT_DETAILS_ERROR, state: DropState.Error)
                break
            default:
                break
            }
        }
    }
    
    /**
     取消点赞
     
     - parameter project_id: 项目id
     */
    func deleteFav(project_id: Int) -> Void {
        let paras = [
            "user_id": Util.getLoginedUser()!.id,
            "project_id": project_id
        ]
        
        NetworkUtil.shareInstance().requestWithUrlWithReturnString(HttpRequest.HTTP_ADDRESS + RequestAddress.HTTP_DELETE_FAV.rawValue, paras: paras) { (response) in
            let state = response.objectForKey(NETWORK_STATE) as! Int
            switch state {
            case NetworkResponseState.CONNECT_FAIL.rawValue:
                // Drop.down(Tips.NETWORK_CONNECT_ERROR, state: DropState.Error)
                break
            case NetworkResponseState.SUCCESS.rawValue:
                // 点赞成功
                self.postNotification(DELETE_FAV_SUCCESS)
            case NetworkResponseState.FAIL.rawValue:
                // Drop.down(Tips.GET_MORE_PROJECT_DETAILS_ERROR, state: DropState.Error)
                break
            default:
                break
            }
        }
    }
}
